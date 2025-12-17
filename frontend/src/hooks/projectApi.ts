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

  if (!init.cache) {
    init.cache = 'no-store';
  }

  if (typeof window !== 'undefined' && 'next' in init) {
    delete init.next;
  }

  const response = await fetch(url, init);

  if (!response.ok) {
    const errorBody = await response.text().catch(() => '');
    throw new Error(
      `Failed to fetch projects (${response.status} ${response.statusText})${errorBody ? `: ${errorBody}` : ''}`,
    );
  }

  try {
    return (await response.json()) as FetchProjectsResult;
  } catch (error) {
    throw new Error('Failed to parse projects response.');
  }
}
