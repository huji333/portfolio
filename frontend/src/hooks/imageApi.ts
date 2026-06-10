import { apiFetch, type ApiRequestInit } from '@/utils/api';
import type { PaginatedImages } from '@/utils/types';

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
  const result = await apiFetch<PaginatedImages>(path, 'images', fetchInit);
  if (result.error) {
    return { images: [], nextCursor: null, hasMore: false, error: true };
  }
  return {
    images: result.data.images,
    nextCursor: result.data.next_cursor,
    hasMore: result.data.has_more,
    error: false,
  };
}
