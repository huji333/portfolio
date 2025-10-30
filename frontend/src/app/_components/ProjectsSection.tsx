import Link from 'next/link';
import ProjectCard from '../projects/_components/ProjectCard';
import { fetchProjects } from '@/hooks/projectApi';
import { use } from 'react';

export default function ProjectsSection() {
  const projects = use(fetchProjects());
  return (
    <section className="bg-background px-6 py-20 md:py-24 snap-ignore" aria-labelledby="projects-heading">
      <div className="mx-auto w-full max-w-5xl">
        <div className="flex flex-row items-center justify-between">
          <h2 id="projects-heading" className="text-2xl font-semibold text-foreground md:text-3xl">
            最近の活動
          </h2>
          <Link
            href="/projects"
            className="inline-flex items-center gap-2 text-sm font-medium text-foreground transition hover:text-blue-600"
          >
            Show More
            <span aria-hidden>→</span>
          </Link>
        </div>

        {projects.length > 0 ? (
          <div className="mt-10 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
            {projects.map((project) => (
              <ProjectCard key={project.id} project={project} />
            ))}
          </div>
        ) : (
          <p className="mt-10 text-sm text-foreground">表示できるプロジェクトがまだありません。</p>
        )}
      </div>
    </section>
  );
}
