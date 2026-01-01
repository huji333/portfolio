import Image from 'next/image';
import { ProjectType } from '@/utils/types';

type ProjectCardProps = {
  project: ProjectType;
};

export default function ProjectCard({ project }: ProjectCardProps) {
  const imageSrc = project.thumbnail ?? project.file;
  const Wrapper = (project.link ? 'a' : 'article') as const;
  const wrapperProps = project.link
    ? {
        href: project.link,
        target: '_blank',
        rel: 'noreferrer noopener',
        'aria-label': `Open ${project.title} in a new tab`,
        role: 'article' as const,
      }
    : {};

  const wrapperClasses = [
    'flex h-full flex-col rounded-2xl border border-accent-light/60 bg-background p-5 shadow-sm transition hover:-translate-y-1 hover:border-accent hover:shadow-lg',
    project.link
      ? 'focus:outline-none focus-visible:ring-2 focus-visible:ring-accent/60 focus-visible:ring-offset-2 focus-visible:ring-offset-background'
      : '',
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <Wrapper className={wrapperClasses} {...wrapperProps}>
      <div className="relative w-full overflow-hidden rounded-xl">
        <div className="aspect-[4/3]" />
        {imageSrc ? (
          <Image
            src={imageSrc}
            alt={project.title}
            fill
            sizes="(min-width: 768px) 33vw, 100vw"
            className="object-contain object-center"
            priority={false}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-xs uppercase tracking-widest text-accent">
            No Image
          </div>
        )}
      </div>
      <div className="mt-5 flex flex-1 flex-col gap-3 text-foreground">
        <h3 className="flex items-center gap-2 text-lg font-semibold text-foreground">
          {project.title}
          {project.link && (
            <span aria-hidden className="text-base text-accent">
              ↗
            </span>
          )}
        </h3>
      </div>
    </Wrapper>
  );
}
