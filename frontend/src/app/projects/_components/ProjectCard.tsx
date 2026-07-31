'use client';

import { useCallback, useState } from 'react';
import Image from 'next/image';
import type { ProjectType } from '@/utils/types';

type ProjectCardProps = {
  project: ProjectType;
};

export default function ProjectCard({ project }: ProjectCardProps) {
  const primarySrc = project.thumbnail ?? project.file;
  const [imageSrc, setImageSrc] = useState(primarySrc);
  const [imgFailed, setImgFailed] = useState(false);

  const handleError = useCallback(
    () => {
      if (imageSrc === project.thumbnail && project.file) {
        setImageSrc(project.file);
      } else {
        setImgFailed(true);
      }
    },
    [imageSrc, project.thumbnail, project.file],
  );

  const wrapperClasses = `flex h-full flex-col rounded-2xl border border-accent-light/60 bg-background p-5 shadow-xs transition hover:-translate-y-1 hover:border-accent hover:shadow-lg${
    project.link
      ? ' focus:outline-hidden focus-visible:ring-2 focus-visible:ring-accent/60 focus-visible:ring-offset-2 focus-visible:ring-offset-background'
      : ''
  }`;

  const content = (
    <>
      <div className="relative w-full overflow-hidden rounded-xl">
        <div className="aspect-4/3" />
        {imageSrc && !imgFailed ? (
          <Image
            src={imageSrc}
            alt={project.title}
            fill
            sizes="(min-width: 768px) 33vw, 100vw"
            className="object-contain object-center"
            priority={false}
            onError={handleError}
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
        {project.description && (
          <p className="text-sm leading-relaxed text-foreground/80">{project.description}</p>
        )}
        {project.tags.length > 0 && (
          <ul className="mt-auto flex flex-wrap gap-2">
            {project.tags.map((tag) => (
              <li
                key={tag}
                className="rounded-full border border-accent-light/60 px-2.5 py-0.5 text-xs text-foreground/70"
              >
                {tag}
              </li>
            ))}
          </ul>
        )}
      </div>
    </>
  );

  const isSafeLink =
    project.link.startsWith('https://') || project.link.startsWith('http://');

  if (isSafeLink) {
    return (
      <a
        href={project.link}
        target="_blank"
        rel="noopener noreferrer"
        aria-label={`Open ${project.title} in a new tab`}
        className={wrapperClasses}
      >
        {content}
      </a>
    );
  }

  return <div className={wrapperClasses}>{content}</div>;
}
