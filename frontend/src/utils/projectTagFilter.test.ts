import { describe, it, expect } from 'vitest';
import {
  buildProjectsHref,
  filterProjectsByTags,
  parseTagsParam,
  toggleTag,
} from './projectTagFilter';
import type { ProjectType } from './types';

const project = (id: number, tags: string[]): ProjectType => ({
  id,
  title: `p${id}`,
  link: null,
  description: null,
  tags,
  file: null,
});

describe('parseTagsParam', () => {
  it('returns [] for undefined and empty', () => {
    expect(parseTagsParam(undefined)).toEqual([]);
    expect(parseTagsParam('')).toEqual([]);
    expect(parseTagsParam(' , ,')).toEqual([]);
  });

  it('splits, trims, dedupes and keeps order', () => {
    expect(parseTagsParam('Rails, Go,Rails,,個人開発')).toEqual(['Rails', 'Go', '個人開発']);
  });

  it('uses the first element of an array', () => {
    expect(parseTagsParam(['Go,Rails', 'Ruby'])).toEqual(['Go', 'Rails']);
  });
});

describe('buildProjectsHref', () => {
  it('returns /projects when empty', () => {
    expect(buildProjectsHref([])).toBe('/projects');
  });

  it('keeps the separator comma literal and encodes non-ASCII', () => {
    expect(buildProjectsHref(['Go', 'Rails'])).toBe('/projects?tags=Go,Rails');
    expect(buildProjectsHref(['個人開発'])).toBe(`/projects?tags=${encodeURIComponent('個人開発')}`);
    expect(buildProjectsHref(['C++', 'a b'])).toBe('/projects?tags=C%2B%2B,a%20b');
  });
});

describe('toggleTag', () => {
  it('appends when absent and removes when present', () => {
    expect(toggleTag(['Go'], 'Rails')).toEqual(['Go', 'Rails']);
    expect(toggleTag(['Go', 'Rails'], 'Go')).toEqual(['Rails']);
  });
});

describe('filterProjectsByTags', () => {
  const projects = [project(1, ['Go']), project(2, ['Rails', 'Ruby']), project(3, [])];

  it('returns all when no tags selected', () => {
    expect(filterProjectsByTags(projects, [])).toEqual(projects);
  });

  it('matches any selected tag (OR) with exact match', () => {
    expect(filterProjectsByTags(projects, ['Go', 'Ruby']).map((p) => p.id)).toEqual([1, 2]);
    expect(filterProjectsByTags(projects, ['go'])).toEqual([]);
  });
});
