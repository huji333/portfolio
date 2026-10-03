'use client';

import { useCallback, useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { buildProjectsHref, toggleTag } from '@/utils/projectTagFilter';
import type { ProjectType } from '@/utils/types';

type ProjectCardProps = {
  project: ProjectType;
  selectedTags?: string[];
};

export default function ProjectCard({ project, selectedTags }: ProjectCardProps) {
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

  // ローカル const に受けてから判定する。project.link のままだと TS が
  // isSafeLink 経由の絞り込みを href まで伝播できず string | null が残る
  const link = project.link;
  const isSafeLink = link !== null && (link.startsWith('https://') || link.startsWith('http://'));
  const selected = selectedTags ?? [];

  const titleContent = (
    <>
      {project.title}
      {isSafeLink && (
        <>
          <span className="sr-only">（新しいタブで開く）</span>
          <span aria-hidden className="text-lg text-accent">
            ↗
          </span>
        </>
      )}
    </>
  );

  return (
    <article className="relative flex h-full flex-col rounded-2xl border border-accent-light/60 bg-background p-5 shadow-xs transition hover:-translate-y-1 hover:border-accent hover:shadow-lg has-[a.card-link:focus-visible]:ring-2 has-[a.card-link:focus-visible]:ring-accent/60 has-[a.card-link:focus-visible]:ring-offset-2 has-[a.card-link:focus-visible]:ring-offset-background">
      <div className="relative w-full overflow-hidden rounded-xl">
        <div className="aspect-4/3" />
        {imageSrc && !imgFailed ? (
          <Image
            src={imageSrc}
            alt={project.title}
            fill
            sizes="(min-width: 768px) 33vw, 100vw"
            className="object-contain object-center"
            onError={handleError}
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-xs uppercase tracking-widest text-accent">
            No Image
          </div>
        )}
      </div>
      <div className="mt-5 flex flex-1 flex-col gap-3 text-foreground">
        <h3 className="text-lg font-semibold text-foreground">
          {isSafeLink ? (
            <a
              href={link}
              target="_blank"
              rel="noopener noreferrer"
              className="card-link flex items-center gap-2 focus:outline-hidden after:absolute after:inset-0 after:content-['']"
            >
              {titleContent}
            </a>
          ) : (
            <span className="flex items-center gap-2">{titleContent}</span>
          )}
        </h3>
        {project.description && (
          <p className="text-sm leading-relaxed text-foreground/80">{project.description}</p>
        )}
        {project.tags.length > 0 && (
          <ul className="mt-auto flex flex-wrap gap-2">
            {project.tags.map((tag) => {
              const isSelected = selected.includes(tag);
              return (
                <li key={tag}>
                  <Link
                    href={buildProjectsHref(toggleTag(selected, tag))}
                    scroll={selectedTags !== undefined ? false : undefined}
                    className={`relative z-10 inline-block rounded-full border px-2.5 py-0.5 text-xs transition hover:border-accent ${
                      isSelected
                        ? 'border-accent bg-accent/10 text-foreground'
                        : 'border-accent-light/60 text-foreground/70'
                    }`}
                  >
                    {tag}
                    {isSelected && <span className="sr-only">（選択中）</span>}
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </article>
  );
}
