import { getApiBaseUrl } from '@/utils/api';
import { ProjectType } from '@/utils/types';

type FetchProjectsInit = RequestInit & {
  next?: {
    revalidate?: number;
  };
};

type FetchProjectsOptions = {
  fetchInit?: FetchProjectsInit;
};

type FetchProjectsResult = ProjectType[];

function buildProjectsUrl(): string {
  return `${getApiBaseUrl()}/projects`;
}

export async function fetchProjects({ fetchInit }: FetchProjectsOptions = {}): Promise<FetchProjectsResult> {
  const url = buildProjectsUrl();
  const init: FetchProjectsInit = fetchInit ? { ...fetchInit } : {};

  if (typeof window !== 'undefined' && 'next' in init) {
    delete init.next;
  }

  try {
    const response = await fetch(url, init);

    if (!response.ok) {
      console.error('Failed to fetch projects:', response.statusText);
      return [];
    }

    return (await response.json()) as FetchProjectsResult;
  } catch (error) {
    console.error('Failed to fetch projects:', error);
    return [];
  }
}
