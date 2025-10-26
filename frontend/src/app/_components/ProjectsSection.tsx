
import Link from 'next/link';
import ProjectCard from '../projects/_components/ProjectCard';
import { ProjectType } from '@/utils/types';

type ProjectsSectionProps = {
  projects: ProjectType[];
};

export default function ProjectsSection({ projects }: ProjectsSectionProps) {
  const hasProjects = projects.length > 0;

  return (
    <section className="bg-base-light px-6 py-20 md:py-24 snap-ignore" aria-labelledby="projects-heading">
      <div className="mx-auto w-full max-w-5xl">
        <div className="flex flex-col gap-8 md:flex-row md:items-end md:justify-between">
          <div>
            <h2 id="projects-heading" className="text-2xl font-bold text-black md:text-3xl">
              最近の活動
            </h2>
            <p className="mt-3 max-w-xl text-base font-medium text-black md:text-lg">
              最近取り組んだ開発や研究へのリンク集です
            </p>
          </div>
          <Link
            href="/projects"
            className="inline-flex items-center gap-2 text-sm font-medium text-foreground transition hover:text-accent"
          >
            すべて見る
            <span aria-hidden>→</span>
          </Link>
        </div>

        {hasProjects ? (
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
