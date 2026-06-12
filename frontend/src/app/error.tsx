'use client';

import { useEffect } from 'react';

export default function Error({
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
    <div className="flex min-h-screen flex-col items-center justify-center gap-6 p-8 text-foreground">
      <p className="text-sm font-medium uppercase tracking-widest text-accent">エラーが発生しました</p>
      <h1 className="text-3xl font-semibold">Something went wrong</h1>
      <p className="max-w-sm text-center text-sm text-foreground/60">
        ページの読み込み中に問題が発生しました。再試行しても解決しない場合はしばらく経ってからアクセスしてください。
      </p>
      <button
        onClick={reset}
        className="rounded-xl border border-accent-light/60 bg-background px-6 py-2.5 text-sm font-medium transition hover:border-accent hover:shadow-md"
      >
        再試行
      </button>
    </div>
  );
}
