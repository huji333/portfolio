import Link from 'next/link';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Page not found',
  robots: { index: false },
};

export default function NotFound() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-6 p-8 text-foreground">
      <p className="text-sm font-medium uppercase tracking-widest text-accent">404</p>
      <h1 className="text-3xl font-semibold">Page not found</h1>
      <p className="max-w-sm text-center text-sm text-foreground/60">
        お探しのページは見つかりませんでした。URL が変更されたか、削除された可能性があります。
      </p>
      <Link
        href="/"
        className="rounded-xl border border-accent-light/60 bg-background px-6 py-2.5 text-sm font-medium transition hover:border-accent hover:shadow-md"
      >
        トップへ戻る
      </Link>
    </div>
  );
}
