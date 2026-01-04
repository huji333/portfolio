import type { NextConfig } from 'next';
import type { RemotePattern } from 'next/dist/shared/lib/image-config';

const remotePatterns: RemotePattern[] = [
  {
    protocol: 'http',
    hostname: 'localhost',
    port: '3000',
    pathname: '/rails/**',
  },
  {
    protocol: 'https',
    hostname: 'huji333-portfolio.s3.ap-northeast-1.amazonaws.com',
    pathname: '/**',
  },
  {
    protocol: 'https',
    hostname: 'portfolio-image-dev.s3.amazonaws.com',
    pathname: '/**',
  },
];

const cloudfrontBaseUrl = process.env.NEXT_PUBLIC_CLOUDFRONT_BASE_URL;
if (cloudfrontBaseUrl) {
  try {
    const parsed = new URL(cloudfrontBaseUrl);
    const protocol = parsed.protocol.replace(':', '');
    if (protocol === 'http' || protocol === 'https') {
      remotePatterns.push({
        protocol,
        hostname: parsed.hostname,
        pathname: '/**',
      });
      console.log('[next.config] Added CloudFront remote pattern:', {
        protocol,
        hostname: parsed.hostname,
      });
    } else {
      console.warn('Unsupported protocol in NEXT_PUBLIC_CLOUDFRONT_BASE_URL:', parsed.protocol);
    }
  } catch (error) {
    console.warn('Invalid NEXT_PUBLIC_CLOUDFRONT_BASE_URL:', error);
  }
} else {
  console.warn('NEXT_PUBLIC_CLOUDFRONT_BASE_URL is not set; CloudFront host will not be allowed in next/image.');
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
