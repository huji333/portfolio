import { apiFetch, ApiRequestInit } from '@/utils/api';
import { ImageType } from '@/utils/types';

type FetchImagesOptions = {
  categoryIds?: number[];
  fetchInit?: ApiRequestInit;
};

type FetchImagesResult = {
  images: ImageType[];
  error: boolean;
};

function buildImagesPath(categoryIds: number[] = []): string {
  const query = categoryIds.length > 0 ? `?categories=${categoryIds.join(',')}` : '';
  return `/images${query}`;
}

export async function fetchImages({
  categoryIds = [],
  fetchInit,
}: FetchImagesOptions = {}): Promise<FetchImagesResult> {
  const path = buildImagesPath(categoryIds);
  const { data, error } = await apiFetch<ImageType[]>(path, 'images', fetchInit);
  return { images: data, error };
}
