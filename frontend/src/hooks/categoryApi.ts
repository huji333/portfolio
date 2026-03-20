import { getApiBaseUrl } from '@/utils/api';
import { CategoryType } from '@/utils/types';

type FetchCategoriesInit = RequestInit & {
  next?: {
    revalidate?: number;
  };
};

type FetchCategoriesOptions = {
  fetchInit?: FetchCategoriesInit;
};

type FetchCategoriesResult = {
  categories: CategoryType[];
  error: boolean;
};

function buildCategoriesUrl(): string {
  return `${getApiBaseUrl()}/categories`;
}

export async function fetchCategories({
  fetchInit,
}: FetchCategoriesOptions = {}): Promise<FetchCategoriesResult> {
  const url = buildCategoriesUrl();
  const init: FetchCategoriesInit = fetchInit ? { ...fetchInit } : {};

  if (typeof window !== 'undefined' && 'next' in init) {
    delete init.next;
  }

  try {
    const response = await fetch(url, init);

    if (!response.ok) {
      console.error('Failed to fetch categories:', response.statusText);
      return { categories: [], error: true };
    }

    const categories = (await response.json()) as CategoryType[];
    return { categories, error: false };
  } catch (error) {
    console.error('Failed to fetch categories:', error);
    return { categories: [], error: true };
  }
}
