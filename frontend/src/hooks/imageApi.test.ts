import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fetchImages } from './imageApi';

vi.mock('@/utils/api', () => ({
  apiFetch: vi.fn(),
}));

import { apiFetch } from '@/utils/api';
const mockApiFetch = vi.mocked(apiFetch);

const emptyPaginated = { images: [], next_cursor: null, has_more: false };

describe('fetchImages', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('fetches all images when no category IDs provided', async () => {
    mockApiFetch.mockResolvedValue({ data: emptyPaginated, error: false });

    await fetchImages();
    expect(mockApiFetch).toHaveBeenCalledWith('/images', 'images', undefined);
  });

  it('builds query string with category IDs', async () => {
    mockApiFetch.mockResolvedValue({ data: emptyPaginated, error: false });

    await fetchImages({ categoryIds: [1, 3] });
    expect(mockApiFetch).toHaveBeenCalledWith('/images?categories=1%2C3', 'images', undefined);
  });

  it('builds query string with cursor', async () => {
    mockApiFetch.mockResolvedValue({ data: emptyPaginated, error: false });

    await fetchImages({ cursor: 'abc123' });
    expect(mockApiFetch).toHaveBeenCalledWith('/images?cursor=abc123', 'images', undefined);
  });

  it('builds query string with category IDs and cursor', async () => {
    mockApiFetch.mockResolvedValue({ data: emptyPaginated, error: false });

    await fetchImages({ categoryIds: [1, 3], cursor: 'abc123' });
    expect(mockApiFetch).toHaveBeenCalledWith('/images?categories=1%2C3&cursor=abc123', 'images', undefined);
  });

  it('returns images, nextCursor, hasMore, and error status on success', async () => {
    const images = [{ id: 1, title: 'Photo' }];
    mockApiFetch.mockResolvedValue({
      data: { images, next_cursor: 'cursor2', has_more: true },
      error: false,
    });

    const result = await fetchImages();
    expect(result).toEqual({
      images,
      nextCursor: 'cursor2',
      hasMore: true,
      error: false,
    });
  });

  it('returns empty result on error', async () => {
    mockApiFetch.mockResolvedValue({ data: emptyPaginated, error: true });

    const result = await fetchImages();
    expect(result).toEqual({
      images: [],
      nextCursor: null,
      hasMore: false,
      error: true,
    });
  });
});
