'use client';

import { useCallback, useEffect, useState } from 'react';
import { fetchTodoItems, setTodoItemLike } from '@/utils/todoApi';
import type { TodoItemType } from '@/utils/types';

const DEVICE_UUID_STORAGE_KEY = 'todo-device-uuid';

// module レベルで memoize し、localStorage が使えない環境（プライベートモード等）
// でもセッション内は同じ UUID を返す
let cachedDeviceUuid: string | null = null;

function getDeviceUuid(): string {
  if (cachedDeviceUuid) return cachedDeviceUuid;
  try {
    const stored = window.localStorage.getItem(DEVICE_UUID_STORAGE_KEY);
    if (stored) {
      cachedDeviceUuid = stored;
    } else {
      cachedDeviceUuid = window.crypto.randomUUID();
      window.localStorage.setItem(DEVICE_UUID_STORAGE_KEY, cachedDeviceUuid);
    }
  } catch {
    cachedDeviceUuid = window.crypto.randomUUID();
  }
  return cachedDeviceUuid;
}

function HeartIcon({ filled }: { filled: boolean }) {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-5 w-5"
      fill={filled ? 'currentColor' : 'none'}
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
    </svg>
  );
}

// 訪問者は操作できない、達成状態を示す表示専用の大きなチェックボックス
function DoneCheckbox({ done }: { done: boolean }) {
  return (
    <span
      aria-hidden="true"
      className={`flex h-7 w-7 shrink-0 items-center justify-center rounded border-2 ${
        done
          ? 'border-neutral-400 bg-neutral-400 dark:border-neutral-500 dark:bg-neutral-500'
          : 'border-foreground'
      }`}
    >
      {done && (
        <svg
          viewBox="0 0 24 24"
          className="h-5 w-5 text-background"
          fill="none"
          stroke="currentColor"
          strokeWidth="3"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          <path d="M20 6 9 17l-5-5" />
        </svg>
      )}
    </span>
  );
}

type TodoAppProps = {
  initialItems: TodoItemType[];
  initialFetchError: boolean;
};

export default function TodoApp({ initialItems, initialFetchError }: TodoAppProps) {
  const [items, setItems] = useState<TodoItemType[]>(initialItems);
  const [fetchError, setFetchError] = useState(initialFetchError);

  // マウント後に device_uuid 付きで取り直し、liked フラグを反映する
  useEffect(() => {
    let cancelled = false;
    fetchTodoItems({ deviceUuid: getDeviceUuid() }).then((result) => {
      if (cancelled || result.error) return;
      setItems(result.items);
      setFetchError(false);
    });
    return () => {
      cancelled = true;
    };
  }, []);

  const toggleLike = useCallback(async (item: TodoItemType) => {
    const nextLiked = !item.liked;

    // optimistic update。失敗したらタップ前のスナップショット（item）に戻す
    setItems((prev) =>
      prev.map((i) =>
        i.id === item.id
          ? { ...i, liked: nextLiked, likes_count: i.likes_count + (nextLiked ? 1 : -1) }
          : i,
      ),
    );

    const result = await setTodoItemLike(item.id, getDeviceUuid(), nextLiked);
    const next = result.error ? item : result.data;
    setItems((prev) => prev.map((i) => (i.id === item.id ? next : i)));
  }, []);

  return (
    <main className="mx-auto max-w-2xl px-5 py-12 md:py-16">
      <header className="mb-6 md:mb-8">
        <h1 className="text-2xl font-bold md:text-3xl">学生生活やりたいことリスト</h1>
        <p className="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
          学生のうちにやっておきたいことたち。♥ で応援できます。
        </p>
      </header>

      {fetchError && items.length === 0 && (
        <p className="text-sm text-neutral-500 dark:text-neutral-400">
          リストを読み込めませんでした。時間をおいて再読み込みしてください。
        </p>
      )}
      {!fetchError && items.length === 0 && (
        <p className="text-sm text-neutral-500 dark:text-neutral-400">まだ項目がありません。</p>
      )}

      <ul className="divide-y divide-black/10 dark:divide-white/10">
        {items.map((item) => (
          <li key={item.id} className="flex items-center gap-4 py-4">
            <DoneCheckbox done={item.done} />
            <div className="min-w-0 flex-1">
              {/* text-base は使わない: @theme の --color-base により色ユーティリティに解決され白文字になる */}
              <p
                className={`font-medium md:text-lg ${
                  item.done ? 'text-neutral-500 dark:text-neutral-400' : ''
                }`}
              >
                {item.title}
              </p>
              {item.note && (
                <p className="mt-0.5 text-sm text-neutral-500 dark:text-neutral-400">{item.note}</p>
              )}
            </div>
            <button
              type="button"
              onClick={() => toggleLike(item)}
              aria-pressed={item.liked}
              aria-label={item.liked ? 'いいねを取り消す' : 'いいねする'}
              className={`flex shrink-0 items-center gap-1 py-1 text-sm transition-colors ${
                item.liked
                  ? 'text-accent'
                  : 'text-neutral-400 hover:text-accent dark:text-neutral-500'
              }`}
            >
              <HeartIcon filled={item.liked} />
              <span className="tabular-nums">{item.likes_count}</span>
            </button>
          </li>
        ))}
      </ul>
    </main>
  );
}
