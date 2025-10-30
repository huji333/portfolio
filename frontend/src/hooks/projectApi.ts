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

function resolveBaseUrl(): string {
  if (process.env.NODE_ENV === 'production') {
    const baseUrl = process.env.API_BASE_URL;
    if (!baseUrl) {
      throw new Error('API_BASE_URL is not defined in production.');
    }
    return baseUrl;
  }

  // Local Docker environment
  return 'http://portfolio-backend-1:3000/api';
}

function buildProjectsUrl(): string {
  return `${resolveBaseUrl()}/projects`;
}

export async function fetchProjects({ fetchInit }: FetchProjectsOptions = {}): Promise<FetchProjectsResult> {
  const url = buildProjectsUrl();
  const init: FetchProjectsInit = fetchInit ? { ...fetchInit } : {};

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
