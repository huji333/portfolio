import type { MetadataRoute } from 'next';
import { getSiteUrl } from '@/utils/site';

export default function robots(): MetadataRoute.Robots {
  const siteUrl = getSiteUrl();

  // フロントは全許可。admin / API は別ホスト（server.kakemu.work）なので対象外。
  return {
    rules: {
      userAgent: '*',
      allow: '/',
    },
    sitemap: `${siteUrl}/sitemap.xml`,
    host: siteUrl,
  };
}
