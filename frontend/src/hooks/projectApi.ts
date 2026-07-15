import { apiFetch, type ApiRequestInit } from '@/utils/api';
import type { ProjectType } from '@/utils/types';

type FetchProjectsOptions = {
  fetchInit?: ApiRequestInit;
};

type FetchProjectsResult = {
  projects: ProjectType[];
  error: boolean;
};

// migration 未適用の DB では as_json が tags キー自体を省略するため、
// レスポンス上は tags が存在しないケースを型として許容し、正規化する。
type ProjectResponse = Omit<ProjectType, 'tags'> & { tags?: string[] };

export async function fetchProjects({
  fetchInit,
}: FetchProjectsOptions = {}): Promise<FetchProjectsResult> {
  const result = await apiFetch<ProjectResponse[]>('/projects', 'projects', fetchInit);
  if (result.error) {
    return { projects: [], error: true };
  }
  const projects = result.data.map((project) => ({ ...project, tags: project.tags ?? [] }));
  return { projects, error: false };
}
