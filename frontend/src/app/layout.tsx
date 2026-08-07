import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { SITE, getSiteUrl } from "@/utils/site";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});

const siteUrl = getSiteUrl();

/** og:site_name が SITE.name なので、og:title は別の文字列にしないとカードの 2 行が重複する */
const ogTitle = `${SITE.nameJa}のポートフォリオ`;

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: `${SITE.nameJa} | ${SITE.name}`,
    template: `%s | ${SITE.name}`,
  },
  description: SITE.description,
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: ogTitle,
    description: SITE.description,
    url: siteUrl,
    siteName: SITE.name,
    locale: SITE.locale,
    type: "website",
    images: [
      {
        url: "/og-image.jpg",
        width: 1200,
        height: 630,
        alt: SITE.name,
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: ogTitle,
    description: SITE.description,
    creator: "@k4kemu",
    images: [{ url: "/og-image.jpg", alt: SITE.name }],
  },
};

const personJsonLd = {
  "@context": "https://schema.org",
  "@type": "Person",
  name: SITE.nameJa,
  alternateName: SITE.name,
  url: siteUrl,
  image: `${siteUrl}/icon_kakemu.jpg`,
  jobTitle: ["Researcher", "Web Developer", "Photographer"],
  description: SITE.description,
  // 表示上の説明からは研究の話を外したが、エンティティとしての強さは JSON-LD 側で維持する
  affiliation: {
    "@type": "CollegeOrUniversity",
    name: "Kyoto University",
  },
  sameAs: SITE.socialLinks,
};

const websiteJsonLd = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: SITE.name,
  url: siteUrl,
  inLanguage: "ja",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body
        className={`${geistSans.variable} antialiased`}
      >
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify([personJsonLd, websiteJsonLd]).replace(/</g, '\\u003c'),
          }}
        />
        {children}
      </body>
    </html>
  );
}
