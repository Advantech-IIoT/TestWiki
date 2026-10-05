# TestWiki

This website is built using [Docusaurus](https://docusaurus.io/), a modern static website generator.

## Installation

```bash
npm install
```

**Note**: feel free to use the package manager of your choice.

## Local Development

```bash
npm run start
```

This command starts a local development server and opens up a browser window. Most changes are reflected live without having to restart the server.

## Build

```bash
npm run build
```

This command generates static content into the `build` directory and can be served using any static contents hosting service.


## CI/CD

### 流程

1. 開 PR 到 `main` → `.github/workflows/validate.yml`（**Validate website**）執行 `npm ci`、`npm run build`、`docker build`。
2. Review 通過並 merge 到 `main`。
3. `.github/workflows/deploy.yml` 的 `build-push` job 建置網站與 Docker image，推送到 GHCR：
   - `ghcr.io/advantech-iiot/testwiki:latest`
   - `ghcr.io/advantech-iiot/testwiki:<commit sha>`
4. `deploy` job（`production` environment）透過 SSH 登入伺服器，`docker pull` 該 sha tag，移除舊的 `testwiki` container，再以 `docker run -d --name testwiki -p 80:80 --restart always` 啟動新版本。

`deploy.yml` 也可從 Actions 頁面以 `workflow_dispatch` 手動觸發。部署使用 `concurrency` group `deploy-production`，同一時間只會有一個部署執行。

### 需要設定的 Secrets

在 **Settings → Secrets and variables → Actions**（或 `production` environment secrets）設定：

| Secret | 說明 |
| --- | --- |
| `DEPLOY_HOST` | 部署伺服器主機名稱或 IP |
| `DEPLOY_USER` | SSH 使用者（需可執行 `docker`） |
| `DEPLOY_KEY` | SSH 私鑰 |
| `GHCR_PAT` | （可選）GHCR package 為 private 時使用，需 `read:packages` 權限的 PAT，伺服器會用它 `docker login ghcr.io` |

推送 image 使用內建的 `GITHUB_TOKEN`，不需額外設定。

### 建議的 GitHub 設定

- **Branch protection（`main`）**：要求 PR、至少一位 reviewer 核准，並將 **Validate website** 設為 required status check。
- **Environment `production`**：於 **Settings → Environments** 建立並設定 required reviewers，部署前需人工核准。

### 回滾

每次部署都會保留 `:<commit sha>` tag。回滾方式：

- 在 Actions 找到舊版本 commit 的 **Deploy TestWiki** run，對其 `deploy` job 執行 **Re-run**，即會重新部署該 sha 的 image；或
- 直接在伺服器上執行：

  ```bash
  docker pull ghcr.io/advantech-iiot/testwiki:<old sha>
  docker rm -f testwiki
  docker run -d --name testwiki -p 80:80 --restart always ghcr.io/advantech-iiot/testwiki:<old sha>
  ```