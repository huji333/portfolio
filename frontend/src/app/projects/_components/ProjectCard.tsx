import Image from 'next/image';
import Link from 'next/link';
import { ProjectType } from '@/utils/types';

type ProjectCardProps = {
  project: ProjectType;
};

export default function ProjectCard({ project }: ProjectCardProps) {
  return (
    <article className="flex h-full flex-col rounded-2xl border border-accent-light/60 bg-base-light p-5 shadow-sm transition hover:-translate-y-1 hover:border-accent hover:shadow-lg">
      <div className="relative w-full overflow-hidden rounded-xl bg-accent-light">
        <div className="aspect-[4/3]" />
        {project.file ? (
          <Image
            src={project.file}
            alt={project.title}
            fill
            sizes="(min-width: 768px) 33vw, 100vw"
            className="object-cover"
            priority={false}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-xs uppercase tracking-widest text-accent">
            No Image
          </div>
        )}
      </div>
      <div className="mt-5 flex flex-1 flex-col gap-3 text-foreground">
        <h3 className="text-lg font-semibold text-foreground">{project.title}</h3>
        {project.link && (
          <Link
            href={project.link}
            target="_blank"
            rel="noreferrer"
            className="mt-auto inline-flex items-center gap-2 text-sm font-medium text-accent hover:text-foreground"
          >
            Visit Project
            <span aria-hidden>→</span>
          </Link>
        )}
      </div>
    </article>
  );
}
