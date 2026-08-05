import { apiFetch, type ApiRequestInit, type ApiResult } from '@/utils/api';
import type { BucketListItemType } from '@/utils/types';

type FetchBucketListItemsOptions = {
  deviceUuid?: string;
  fetchInit?: ApiRequestInit;
};

type FetchBucketListItemsResult = {
  items: BucketListItemType[];
  error: boolean;
};

export async function fetchBucketListItems({
  deviceUuid,
  fetchInit,
}: FetchBucketListItemsOptions = {}): Promise<FetchBucketListItemsResult> {
  const query = deviceUuid ? `?device_uuid=${encodeURIComponent(deviceUuid)}` : '';
  const result = await apiFetch<BucketListItemType[]>(`/bucket_list_items${query}`, 'bucket list items', fetchInit);
  if (result.error) {
    return { items: [], error: true };
  }
  return { items: result.data, error: false };
}

// device_uuid は body ではなく query で送る（Rails 側で DELETE の body パースに
// 依存しないようにし、POST/DELETE を対称にする）。成功時は更新後のアイテム全体が返る
export async function setBucketListItemLike(
  id: number,
  deviceUuid: string,
  liked: boolean,
): Promise<ApiResult<BucketListItemType>> {
  const query = `?device_uuid=${encodeURIComponent(deviceUuid)}`;
  return apiFetch<BucketListItemType>(`/bucket_list_items/${id}/like${query}`, 'bucket list like', {
    method: liked ? 'POST' : 'DELETE',
  });
}
