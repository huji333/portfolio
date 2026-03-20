import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fetchImages } from './imageApi';

vi.mock('@/utils/api', () => ({
  apiFetch: vi.fn(),
}));

import { apiFetch } from '@/utils/api';
const mockApiFetch = vi.mocked(apiFetch);

describe('fetchImages', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('fetches all images when no category IDs provided', async () => {
    mockApiFetch.mockResolvedValue({ data: [], error: false });

    await fetchImages();
    expect(mockApiFetch).toHaveBeenCalledWith('/images', 'images', undefined);
  });

  it('builds query string with category IDs', async () => {
    mockApiFetch.mockResolvedValue({ data: [], error: false });

    await fetchImages({ categoryIds: [1, 3] });
    expect(mockApiFetch).toHaveBeenCalledWith('/images?categories=1,3', 'images', undefined);
  });

  it('returns images and error status', async () => {
    const images = [{ id: 1, title: 'Photo' }];
    mockApiFetch.mockResolvedValue({ data: images, error: false });

    const result = await fetchImages();
    expect(result).toEqual({ images, error: false });
  });
});
