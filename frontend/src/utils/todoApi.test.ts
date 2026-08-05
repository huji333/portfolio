import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fetchTodoItems, setTodoItemLike } from './todoApi';

vi.mock('@/utils/api', () => ({
  apiFetch: vi.fn(),
}));

import { apiFetch } from '@/utils/api';
const mockApiFetch = vi.mocked(apiFetch);

const baseItem = {
  id: 1,
  title: '富士山に登る',
  note: null,
  done: false,
  likes_count: 0,
  liked: false,
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe('fetchTodoItems', () => {
  it('requests without device_uuid when none is given', async () => {
    mockApiFetch.mockResolvedValue({ data: [baseItem], error: false });

    const result = await fetchTodoItems();

    expect(mockApiFetch).toHaveBeenCalledWith('/todo_items', 'todo items', undefined);
    expect(result).toEqual({ items: [baseItem], error: false });
  });

  it('appends the encoded device_uuid to the query', async () => {
    mockApiFetch.mockResolvedValue({ data: [], error: false });

    await fetchTodoItems({ deviceUuid: 'abc/123' });

    expect(mockApiFetch).toHaveBeenCalledWith(
      '/todo_items?device_uuid=abc%2F123',
      'todo items',
      undefined,
    );
  });

  it('returns empty items on error', async () => {
    mockApiFetch.mockResolvedValue({ data: null, error: true });

    const result = await fetchTodoItems();
    expect(result).toEqual({ items: [], error: true });
  });
});

describe('setTodoItemLike', () => {
  it('POSTs when liking and returns the updated item', async () => {
    const updated = { ...baseItem, likes_count: 1, liked: true };
    mockApiFetch.mockResolvedValue({ data: updated, error: false });

    const result = await setTodoItemLike(1, 'device-1', true);

    expect(mockApiFetch).toHaveBeenCalledWith('/todo_items/1/like?device_uuid=device-1', 'todo like', {
      method: 'POST',
    });
    expect(result).toEqual({ data: updated, error: false });
  });

  it('DELETEs when unliking', async () => {
    mockApiFetch.mockResolvedValue({ data: baseItem, error: false });

    const result = await setTodoItemLike(1, 'device-1', false);

    expect(mockApiFetch).toHaveBeenCalledWith('/todo_items/1/like?device_uuid=device-1', 'todo like', {
      method: 'DELETE',
    });
    expect(result).toEqual({ data: baseItem, error: false });
  });

  it('passes the error result through', async () => {
    mockApiFetch.mockResolvedValue({ data: null, error: true });

    const result = await setTodoItemLike(1, 'device-1', true);
    expect(result).toEqual({ data: null, error: true });
  });
});
