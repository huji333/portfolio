import Link from 'next/link';
import { fetchProjects, PROJECT_REVALIDATE_SECONDS } from '@/utils/projectApi';
import { buildProjectsHref, filterProjectsByTags, parseTagsParam, toggleTag } from '@/utils/projectTagFilter';
import ProjectCard from './ProjectCard';

type ProjectAppProps = {
  searchParams: Promise<{ tags?: string | string[] }>;
};

export default async function ProjectApp({ searchParams }: ProjectAppProps) {
  const { tags: tagsParam } = await searchParams;
  const selectedTags = parseTagsParam(tagsParam);
  const { projects, error } = await fetchProjects({ fetchInit: { next: { revalidate: PROJECT_REVALIDATE_SECONDS } } });
  const filtered = filterProjectsByTags(projects, selectedTags);

  return (
    <section className="mx-auto w-full max-w-6xl px-4 py-20">
      <h1 className="mb-8 text-2xl font-semibold text-foreground">Projects</h1>
      <p className="mb-8 text-sm text-foreground">最近の活動の紹介です。ブログ記事や外部リンクが置いてあります。</p>
      {selectedTags.length > 0 && (
        <div role="group" aria-label="選択中のタグ" className="mb-6 flex flex-wrap items-center gap-2">
          <span className="text-sm text-foreground/80">絞り込み中（いずれかを含む）</span>
          {selectedTags.map((tag) => (
            <Link
              key={tag}
              href={buildProjectsHref(toggleTag(selectedTags, tag))}
              scroll={false}
              aria-label={`${tag} の絞り込みを解除`}
              className="inline-flex items-center gap-1 rounded-full border border-accent bg-accent/10 px-3 py-1 text-xs text-foreground transition hover:bg-accent/20 sm:text-sm"
            >
              {tag}
              <span aria-hidden>×</span>
            </Link>
          ))}
          <Link href="/projects" scroll={false} className="text-xs text-foreground/70 underline sm:text-sm">
            すべて解除
          </Link>
        </div>
      )}
      {error && (
        <p className="mb-4 text-center text-sm text-red-600">読み込みに失敗しました。</p>
      )}
      {!error && projects.length === 0 && (
        <p className="mb-4 text-center text-sm text-foreground">表示できるプロジェクトがまだありません。</p>
      )}
      {!error && projects.length > 0 && filtered.length === 0 && (
        <div className="mb-4 text-center text-sm text-foreground">
          <p>選択したタグに一致するプロジェクトはありません。</p>
          <Link href="/projects" scroll={false} className="mt-2 inline-block underline">
            絞り込みを解除
          </Link>
        </div>
      )}
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {filtered.map((project) => (
          <ProjectCard key={project.id} project={project} selectedTags={selectedTags} />
        ))}
      </div>
    </section>
  );
}
