#!/usr/bin/env bash
# Pull the latest TestWiki image and restart the container only when the image changed.
# Intended to run from cron, e.g.: */5 * * * * /usr/local/bin/testwiki-update.sh
set -euo pipefail

IMG="${IMG:-ghcr.io/advantech-iiot/testwiki:latest}"
CONTAINER="${CONTAINER:-testwiki}"
PORT="${PORT:-80}"
LOG_FILE="${LOG_FILE:-/var/log/testwiki-update.log}"
LOCK_FILE="${LOCK_FILE:-/tmp/testwiki-update.lock}"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

exec 9> "$LOCK_FILE"
if ! flock -n 9; then
  log "another update is running, skip"
  exit 0
fi

if ! docker pull -q "$IMG" >> "$LOG_FILE" 2>&1; then
  log "ERROR: docker pull $IMG failed"
  exit 1
fi

new_id="$(docker image inspect --format '{{.Id}}' "$IMG")"
current_id="$(docker container inspect --format '{{.Image}}' "$CONTAINER" 2>/dev/null || true)"

if [ "$new_id" = "$current_id" ]; then
  exit 0
fi

log "updating $CONTAINER: ${current_id:-<none>} -> $new_id ($IMG)"
docker rm -f "$CONTAINER" >> "$LOG_FILE" 2>&1 || true
docker run -d --name "$CONTAINER" -p "$PORT:80" --restart always "$IMG" >> "$LOG_FILE" 2>&1
docker image prune -f >> "$LOG_FILE" 2>&1
log "update done"
