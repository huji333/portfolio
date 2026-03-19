import type { Metadata } from 'next';
import Header from '@/ui/Header';
import { HEADER_STYLE_PRESETS } from '@/ui/headerStyles';
import GalleryApp from './_components/GalleryApp';
import type { CategoryType, ImageType } from '@/utils/types';
import { getApiBaseUrl } from '@/utils/api';
import { fetchImages } from '@/hooks/imageApi';

export const metadata: Metadata = {
  title: 'Gallery',
};

async function fetchCategories(): Promise<CategoryType[]> {
  const baseUrl = getApiBaseUrl();

  try {
    const response = await fetch(`${baseUrl}/categories`, {
      next: { revalidate: 300 },
    });

    if (!response.ok) {
      console.error('Failed to fetch categories:', response.statusText);
      return [];
    }

    return (await response.json()) as CategoryType[];
  } catch (error) {
    console.error('Failed to fetch categories:', error);
    return [];
  }
}

async function fetchInitialImages(): Promise<ImageType[]> {
  const result = await fetchImages({
    fetchInit: {
      next: { revalidate: 120 },
    },
  });
  return result.images;
}

export default async function Page() {
  const [categories, initialImages] = await Promise.all([fetchCategories(), fetchInitialImages()]);

  return (
    <>
      <Header styles={HEADER_STYLE_PRESETS.solid} />
      <div className="min-h-screen bg-background pt-20 md:pt-24">
        <GalleryApp initialCategories={categories} initialImages={initialImages} />
      </div>
    </>
  );
}
