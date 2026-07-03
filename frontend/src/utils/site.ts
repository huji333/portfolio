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
  /** 京大で昆虫の研究をしながら web 開発と写真をやっている、が伝わる説明 */
  description:
    '京都大学で昆虫が葉につける食痕を研究する傍ら、web 開発と写真撮影をしている藤井駆陸のポートフォリオ。プロジェクトと写真作品をまとめています。',
  locale: 'ja_JP',
  /** JSON-LD Person / OGP profile に使う SNS プロフィール URL */
  socialLinks: [
    'https://x.com/k4kemu',
    'https://www.instagram.com/fuji_sn4p',
    'https://github.com/huji333',
  ],
} as const;
