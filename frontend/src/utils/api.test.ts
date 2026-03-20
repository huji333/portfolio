import { describe, it, expect, vi, beforeEach } from 'vitest';
import { getApiBaseUrl, apiFetch } from './api';

describe('getApiBaseUrl', () => {
  beforeEach(() => {
    vi.unstubAllEnvs();
  });

  it('returns default URL when no env vars are set', () => {
    vi.stubEnv('API_BASE_URL', '');
    vi.stubEnv('NEXT_PUBLIC_API_BASE_URL', '');
    expect(getApiBaseUrl()).toBe('http://localhost:3000/api');
  });

  it('uses API_BASE_URL when set', () => {
    vi.stubEnv('API_BASE_URL', 'https://example.com/api');
    expect(getApiBaseUrl()).toBe('https://example.com/api');
  });

  it('strips trailing slash', () => {
    vi.stubEnv('API_BASE_URL', 'https://example.com/api/');
    expect(getApiBaseUrl()).toBe('https://example.com/api');
  });
});

describe('apiFetch', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
    vi.stubEnv('API_BASE_URL', 'https://api.test');
  });

  it('returns data on successful response', async () => {
    const mockData = [{ id: 1, name: 'test' }];
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve(mockData),
    }));

    const result = await apiFetch('/items', 'items');
    expect(result).toEqual({ data: mockData, error: false });
    expect(fetch).toHaveBeenCalledWith('https://api.test/items', undefined);
  });

  it('returns empty array and error on non-ok response', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
      ok: false,
      statusText: 'Not Found',
    }));

    const result = await apiFetch('/items', 'items');
    expect(result).toEqual({ data: [], error: true });
  });

  it('returns empty array and error on network failure', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new Error('Network error')));

    const result = await apiFetch('/items', 'items');
    expect(result).toEqual({ data: [], error: true });
  });
});
