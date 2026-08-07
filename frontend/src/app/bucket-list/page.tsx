import type { Metadata } from 'next';
import { fetchBucketListItems } from '@/utils/bucketListApi';
import BucketListApp from './_components/BucketListApp';

// 単体で共有されることを前提にしたページなので、og も親任せにせず個別に持たせる
const description = '藤井駆陸が学生のうちにやっておきたいことのリスト。達成状況を公開しています。♥ で応援できます。';

export const metadata: Metadata = {
  title: '学生生活やりたいことリスト',
  description,
  alternates: {
    canonical: '/bucket-list',
  },
  openGraph: {
    title: '学生生活やりたいことリスト | Kakemu Fujii',
    description,
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
