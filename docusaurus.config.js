const config = {
  title: 'Test Wiki',
  tagline: 'Internal Knowledge Base',

  // 初期本機／PoC 使用；之後改成 Ubuntu IP 或正式網域。
  url: 'http://localhost:8080',
  baseUrl: '/',

  organizationName: 'ginocowork',
  projectName: 'TestWiki',

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'zh-Hant',
    locales: ['zh-Hant'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          showLastUpdateAuthor: true,
          showLastUpdateTime: true,
          editUrl:
            'https://github.com/ginocowork/TestWiki/edit/main/',
        },

        blog: false,

        theme: {
          customCss: './src/css/custom.css',
        },
      },
    ],
  ],

  themeConfig: {
    navbar: {
      title: 'Test Wiki',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'wikiSidebar',
          label: 'Wiki',
          position: 'left',
        },
        {
          href: 'https://github.com/ginocowork/TestWiki',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },

    footer: {
      style: 'dark',
      copyright:
        `Copyright © ${new Date().getFullYear()} Test Wiki`,
    },
  },
};

export default config;