import type { Metadata } from 'next';
import { fetchBucketListItems } from '@/utils/bucketListApi';
import BucketListApp from './_components/BucketListApp';

export const metadata: Metadata = {
  title: 'やりたいことリスト',
  description: '学生生活でやりたいことリスト',
  alternates: {
    canonical: '/bucket-list',
  },
};

export default async function BucketListPage() {
  // liked はデバイス依存なので server では取れない。クライアント側で
  // device_uuid 付きで再取得して上書きする
  const { items, error } = await fetchBucketListItems({
    fetchInit: { next: { revalidate: 60 } },
  });

  return <BucketListApp initialItems={items} initialFetchError={error} />;
}
