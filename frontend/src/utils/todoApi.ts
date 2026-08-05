import { apiFetch, type ApiRequestInit, type ApiResult } from '@/utils/api';
import type { TodoItemType } from '@/utils/types';

type FetchTodoItemsOptions = {
  deviceUuid?: string;
  fetchInit?: ApiRequestInit;
};

type FetchTodoItemsResult = {
  items: TodoItemType[];
  error: boolean;
};

export async function fetchTodoItems({
  deviceUuid,
  fetchInit,
}: FetchTodoItemsOptions = {}): Promise<FetchTodoItemsResult> {
  const query = deviceUuid ? `?device_uuid=${encodeURIComponent(deviceUuid)}` : '';
  const result = await apiFetch<TodoItemType[]>(`/todo_items${query}`, 'todo items', fetchInit);
  if (result.error) {
    return { items: [], error: true };
  }
  return { items: result.data, error: false };
}

// device_uuid は body ではなく query で送る（Rails 側で DELETE の body パースに
// 依存しないようにし、POST/DELETE を対称にする）。成功時は更新後のアイテム全体が返る
export async function setTodoItemLike(
  id: number,
  deviceUuid: string,
  liked: boolean,
): Promise<ApiResult<TodoItemType>> {
  const query = `?device_uuid=${encodeURIComponent(deviceUuid)}`;
  return apiFetch<TodoItemType>(`/todo_items/${id}/like${query}`, 'todo like', {
    method: liked ? 'POST' : 'DELETE',
  });
}
