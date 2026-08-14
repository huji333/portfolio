import type { Metadata } from 'next';
import SiteHeader from '../_components/SiteHeader';
import GalleryApp from './_components/GalleryApp';
import { fetchCategories, CATEGORY_REVALIDATE_SECONDS } from '@/utils/categoryApi';
import { fetchImages, IMAGE_REVALIDATE_SECONDS } from '@/utils/imageApi';

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
    fetchCategories({ fetchInit: { next: { revalidate: CATEGORY_REVALIDATE_SECONDS } } }),
    fetchImages({ fetchInit: { next: { revalidate: IMAGE_REVALIDATE_SECONDS } } }),
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
