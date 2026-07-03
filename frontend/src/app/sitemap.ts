import type { MetadataRoute } from 'next';
import { getSiteUrl } from '@/utils/site';

export default function sitemap(): MetadataRoute.Sitemap {
  const siteUrl = getSiteUrl();

  // 静的ルート。ブログ実装後（#198）はここに記事 URL を動的追加する。
  const routes: { path: string; priority: number }[] = [
    { path: '/', priority: 1 },
    { path: '/gallery', priority: 0.8 },
    { path: '/projects', priority: 0.8 },
    { path: '/contact', priority: 0.5 },
  ];

  return routes.map(({ path, priority }) => ({
    url: `${siteUrl}${path}`,
    changeFrequency: 'weekly',
    priority,
  }));
}
