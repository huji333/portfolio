import { apiFetch, type ApiRequestInit } from '@/utils/api';
import type { CategoryType } from '@/utils/types';

export const CATEGORY_REVALIDATE_SECONDS = 300;

type FetchCategoriesOptions = {
  fetchInit?: ApiRequestInit;
};

type FetchCategoriesResult = {
  categories: CategoryType[];
  error: boolean;
};

export async function fetchCategories({
  fetchInit,
}: FetchCategoriesOptions = {}): Promise<FetchCategoriesResult> {
  const result = await apiFetch<CategoryType[]>('/categories', 'categories', fetchInit);
  return { categories: result.error ? [] : result.data, error: result.error };
}
