import { apiFetch, ApiRequestInit } from '@/utils/api';
import { PaginatedImages } from '@/utils/types';

type FetchImagesOptions = {
  categoryIds?: number[];
  cursor?: string | null;
  fetchInit?: ApiRequestInit;
};

type FetchImagesResult = {
  images: PaginatedImages['images'];
  nextCursor: string | null;
  hasMore: boolean;
  error: boolean;
};

function buildImagesPath(categoryIds: number[] = [], cursor?: string | null): string {
  const params = new URLSearchParams();
  if (categoryIds.length > 0) {
    params.set('categories', categoryIds.join(','));
  }
  if (cursor) {
    params.set('cursor', cursor);
  }
  const query = params.toString();
  return `/images${query ? `?${query}` : ''}`;
}

export async function fetchImages({
  categoryIds = [],
  cursor,
  fetchInit,
}: FetchImagesOptions = {}): Promise<FetchImagesResult> {
  const path = buildImagesPath(categoryIds, cursor);
  const { data, error } = await apiFetch<PaginatedImages>(path, 'images', fetchInit);
  if (error) {
    return { images: [], nextCursor: null, hasMore: false, error: true };
  }
  return {
    images: data.images,
    nextCursor: data.next_cursor,
    hasMore: data.has_more,
    error: false,
  };
}
