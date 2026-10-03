import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import ProjectCard from './ProjectCard';
import type { ProjectType } from '@/utils/types';

const project: ProjectType = {
  id: 1,
  title: 'My App',
  link: 'https://example.com/app',
  description: 'desc',
  tags: ['Go', 'Rails'],
  file: null,
};

describe('ProjectCard', () => {
  it('never nests an anchor inside another anchor', () => {
    const { container } = render(<ProjectCard project={project} />);
    expect(container.querySelectorAll('a a')).toHaveLength(0);
  });

  it('links the title to project.link in a new tab', () => {
    render(<ProjectCard project={project} />);
    const link = screen.getByRole('link', { name: /My App/ });
    expect(link).toHaveAttribute('href', 'https://example.com/app');
    expect(link).toHaveAttribute('target', '_blank');
  });

  it('renders a plain title when the link is unsafe', () => {
    render(<ProjectCard project={{ ...project, link: 'javascript:alert(1)' }} />);
    expect(screen.queryByRole('link', { name: /My App/ })).toBeNull();
  });

  it('builds tag hrefs without selectedTags', () => {
    render(<ProjectCard project={project} />);
    expect(screen.getByRole('link', { name: 'Rails' })).toHaveAttribute('href', '/projects?tags=Rails');
  });

  it('adds to and removes from the selection via tag hrefs', () => {
    render(<ProjectCard project={project} selectedTags={['Go']} />);
    expect(screen.getByRole('link', { name: 'Rails' })).toHaveAttribute('href', '/projects?tags=Go,Rails');
    // 選択中の Go を押すと解除される
    expect(screen.getByRole('link', { name: /^Go/ })).toHaveAttribute('href', '/projects');
  });
});
