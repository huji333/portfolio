import type { Metadata } from 'next';
import { fetchTodoItems } from '@/utils/todoApi';
import TodoApp from './_components/TodoApp';

export const metadata: Metadata = {
  title: 'やりたいことリスト',
  description: '学生生活でやりたいことリスト',
  alternates: {
    canonical: '/todo',
  },
};

export default async function TodoPage() {
  // liked はデバイス依存なので server では取れない。クライアント側で
  // device_uuid 付きで再取得して上書きする
  const { items, error } = await fetchTodoItems({
    fetchInit: { next: { revalidate: 60 } },
  });

  return <TodoApp initialItems={items} initialFetchError={error} />;
}
