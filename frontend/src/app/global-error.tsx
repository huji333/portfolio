'use client';

import { useEffect } from 'react';

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <html lang="ja">
      <body>
        <div className="flex min-h-screen flex-col items-center justify-center gap-6 p-8 text-center">
          <p className="text-sm font-medium uppercase tracking-widest" style={{ color: '#6D94C5' }}>
            エラーが発生しました
          </p>
          <h1 className="text-3xl font-semibold">Something went wrong</h1>
          <p className="max-w-sm text-sm" style={{ opacity: 0.6 }}>
            ページの読み込み中に問題が発生しました。再試行しても解決しない場合はしばらく経ってからアクセスしてください。
          </p>
          <button
            onClick={reset}
            className="rounded-xl border px-6 py-2.5 text-sm font-medium transition hover:shadow-md"
          >
            再試行
          </button>
        </div>
      </body>
    </html>
  );
}
