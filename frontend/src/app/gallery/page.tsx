import type { Metadata } from 'next';
import Header from '@/ui/Header';
import { HEADER_STYLE_PRESETS } from '@/ui/headerStyles';
import GalleryApp from './_components/GalleryApp';
import { fetchCategories } from '@/hooks/categoryApi';
import { fetchImages } from '@/hooks/imageApi';

export const metadata: Metadata = {
  title: 'Gallery',
};

export default async function Page() {
  const [categoriesResult, imagesResult] = await Promise.all([
    fetchCategories({ fetchInit: { next: { revalidate: 300 } } }),
    fetchImages({ fetchInit: { next: { revalidate: 120 } } }),
  ]);

  const categories = categoriesResult.categories;
  const initialImages = imagesResult.images;

  return (
    <>
      <Header styles={HEADER_STYLE_PRESETS.solid} />
      <div className="min-h-screen bg-background pt-20 md:pt-24">
        <GalleryApp initialCategories={categories} initialImages={initialImages} />
      </div>
    </>
  );
}
