/**
 * サイト全体のメタ情報を single-source で管理する。
 * metadata / sitemap / robots / JSON-LD から参照される。
 */

export function getSiteUrl(): string {
  const rawUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://kakemu.work';
  return rawUrl.endsWith('/') ? rawUrl.slice(0, -1) : rawUrl;
}

export const SITE = {
  name: 'Kakemu Fujii',
  /** 日本語表記。「藤井駆陸」と「kakemu」どちらの名前検索でも拾えるよう title に併記する */
  nameJa: '藤井駆陸',
  /**
   * 名前を先頭に置く。Google のモバイル SERP は全角 50 字前後で切られるため、
   * 後ろに置くと最有力の流入経路である名前検索で名前が表示されないまま切れる。
   */
  description:
    '藤井駆陸（Kakemu Fujii）のポートフォリオ。web 開発のプロジェクトと写真作品をまとめています。',
  locale: 'ja_JP',
  /** JSON-LD Person / OGP profile に使う SNS プロフィール URL */
  socialLinks: [
    'https://x.com/k4kemu',
    'https://www.instagram.com/fuji_sn4p',
    'https://github.com/huji333',
  ],
} as const;
