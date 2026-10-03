import type { ProjectType } from '@/utils/types';

export function parseTagsParam(value: string | string[] | undefined): string[] {
  const raw = Array.isArray(value) ? value[0] : value;
  if (!raw) return [];
  const tags = raw
    .split(',')
    .map((tag) => tag.trim())
    .filter((tag) => tag !== '');
  return [...new Set(tags)];
}

// 区切りの comma はリテラルのまま残したいので URLSearchParams は使わない
export function buildProjectsHref(tags: string[]): string {
  if (tags.length === 0) return '/projects';
  return `/projects?tags=${tags.map(encodeURIComponent).join(',')}`;
}

export function toggleTag(tags: string[], tag: string): string[] {
  return tags.includes(tag) ? tags.filter((t) => t !== tag) : [...tags, tag];
}

export function filterProjectsByTags(projects: ProjectType[], tags: string[]): ProjectType[] {
  if (tags.length === 0) return projects;
  return projects.filter((project) => project.tags.some((tag) => tags.includes(tag)));
}
