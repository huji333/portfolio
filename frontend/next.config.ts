import type { NextConfig } from 'next';
import type { RemotePattern } from 'next/dist/shared/lib/image-config';

const remotePatterns: RemotePattern[] = [
  {
    protocol: 'http',
    hostname: 'localhost',
    port: '3000',
    pathname: '/rails/**',
  },
];

function addRemotePatternFromUrl(url: string, label: string): void {
  try {
    const parsed = new URL(url);
    const protocol = parsed.protocol.replace(':', '');
    if (protocol === 'http' || protocol === 'https') {
      remotePatterns.push({ protocol, hostname: parsed.hostname, pathname: '/**' });
    } else {
      console.warn(`[next.config] Unsupported protocol in ${label}:`, parsed.protocol);
    }
  } catch (error) {
    console.warn(`[next.config] Invalid ${label}:`, error);
  }
}

const cloudfrontBaseUrl = process.env.NEXT_PUBLIC_CLOUDFRONT_BASE_URL;
if (cloudfrontBaseUrl) {
  addRemotePatternFromUrl(cloudfrontBaseUrl, 'NEXT_PUBLIC_CLOUDFRONT_BASE_URL');
} else {
  console.warn('[next.config] NEXT_PUBLIC_CLOUDFRONT_BASE_URL is not set; CloudFront images will not be allowed.');
}

// S3 direct-access hostname (optional; set NEXT_PUBLIC_S3_HOSTNAME to e.g. "mybucket.s3.ap-northeast-1.amazonaws.com")
const s3Hostname = process.env.NEXT_PUBLIC_S3_HOSTNAME;
if (s3Hostname) {
  addRemotePatternFromUrl(`https://${s3Hostname}`, 'NEXT_PUBLIC_S3_HOSTNAME');
}

const nextConfig: NextConfig = {
  webpack(config) {
    config.module.rules.push({
      test: /\.svg$/,
      use: [
        {
          loader: '@svgr/webpack',
          options: {
            svgoConfig: {
              plugins: [
                {
                  name: 'removeViewBox',
                  active: false,
                },
              ],
            },
          },
        },
      ],
    });
    return config;
  },
  images: {
    remotePatterns,
  },
};

export default nextConfig;
