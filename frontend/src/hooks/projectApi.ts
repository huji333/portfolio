import { apiFetch, ApiRequestInit } from '@/utils/api';
import { ProjectType } from '@/utils/types';

type FetchProjectsOptions = {
  fetchInit?: ApiRequestInit;
};

type FetchProjectsResult = {
  projects: ProjectType[];
  error: boolean;
};

export async function fetchProjects({
  fetchInit,
}: FetchProjectsOptions = {}): Promise<FetchProjectsResult> {
  const { data, error } = await apiFetch<ProjectType[]>('/projects', 'projects', fetchInit);
  return { projects: data, error };
}
