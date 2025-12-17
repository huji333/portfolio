import { ImageType } from '@/utils/types';
import { getApiBaseUrl } from '@/utils/api';

type FetchImagesOptions = {
  categoryIds?: number[];
  fetchInit?: RequestInit;
};

type FetchImagesResult = ImageType[];

function buildImagesUrl(categoryIds: number[] = []): string {
  const baseUrl = getApiBaseUrl();
  const query = categoryIds.length > 0 ? `?categories=${categoryIds.join(',')}` : '';
  return `${baseUrl}/images${query}`;
}

export async function fetchImages({ categoryIds = [], fetchInit }: FetchImagesOptions = {}): Promise<FetchImagesResult> {
  const url = buildImagesUrl(categoryIds);

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
