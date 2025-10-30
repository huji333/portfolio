import { fetchProjects } from '@/hooks/projectApi';
import ProjectCard from './ProjectCard';
import { use } from 'react';

export default function ProjectApp() {
  const projects = use(fetchProjects());

  return (
    <section className="mx-auto w-full max-w-6xl px-4 py-20">
      <h1 className="mb-8 text-2xl font-semibold text-foreground">Projects</h1>
      <p className="mb-8 text-sm text-foreground">最近の活動の紹介です。ブログ記事や外部リンクが置いてあります。</p>
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {projects.map((project) => (
          <ProjectCard key={project.id} project={project} />
        ))}
      </div>
    </section>
  );
}
