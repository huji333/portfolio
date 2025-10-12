import { ImageType } from '@/utils/types';

type FetchImagesOptions = {
  categoryIds?: number[];
  fetchInit?: RequestInit;
};

type FetchImagesResult = ImageType[];

function buildImagesUrl(categoryIds: number[] = []): string | null {
  const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
  if (!baseUrl) {
    console.warn('NEXT_PUBLIC_API_BASE_URL is not defined.');
    return null;
  }

  const query = categoryIds.length > 0 ? `?categories=${categoryIds.join(',')}` : '';
  return `${baseUrl}/images${query}`;
}

export async function fetchImages({ categoryIds = [], fetchInit }: FetchImagesOptions = {}): Promise<FetchImagesResult> {
  const url = buildImagesUrl(categoryIds);
  if (!url) {
    return [];
  }

  const init = fetchInit ? { ...fetchInit } : undefined;
  if (typeof window !== 'undefined' && init && 'next' in init) {
    // `next` options are only understood by Next.js server-side fetch. Remove for browser fetches.
    delete (init as Record<string, unknown>).next;
  }

  try {
    const response = await fetch(url, init);
    if (!response.ok) {
      console.error('Failed to fetch images', response.statusText);
      return [];
    }

    return (await response.json()) as FetchImagesResult;
  } catch (error) {
    console.error('Failed to fetch images', error);
    return [];
  }
}
