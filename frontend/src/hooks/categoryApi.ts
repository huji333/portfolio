import { apiFetch, ApiRequestInit } from '@/utils/api';
import { CategoryType } from '@/utils/types';

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
  const { data, error } = await apiFetch<CategoryType[]>('/categories', 'categories', fetchInit);
  return { categories: data, error };
}
