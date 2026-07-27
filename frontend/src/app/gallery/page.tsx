import type { Metadata } from 'next';
import SiteHeader from '../_components/SiteHeader';
import GalleryApp from './_components/GalleryApp';
import { fetchCategories } from '@/utils/categoryApi';
import { fetchImages } from '@/utils/imageApi';

const description = '藤井駆陸が撮影した写真作品のギャラリー。フィールドワークの記録から日常のスナップまで、カテゴリ別に閲覧できます。';

export const metadata: Metadata = {
  title: 'Gallery',
  description,
  openGraph: {
    title: 'Gallery | Kakemu Fujii',
    description,
  },
};

export default async function Page() {
  const [categoriesResult, imagesResult] = await Promise.all([
    fetchCategories({ fetchInit: { next: { revalidate: 300 } } }),
    fetchImages({ fetchInit: { next: { revalidate: 120 } } }),
  ]);

  return (
    <>
      <SiteHeader />
      <div className="min-h-screen bg-background pt-20 md:pt-24">
        <GalleryApp
          initialCategories={categoriesResult.categories}
          initialImages={imagesResult.images}
          initialNextCursor={imagesResult.nextCursor}
          initialHasMore={imagesResult.hasMore}
          initialFetchError={imagesResult.error || categoriesResult.error}
        />
      </div>
    </>
  );
}
