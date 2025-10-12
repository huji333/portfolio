import Link from "next/link";
import Header from "../components/layout/Header";
import ProjectCard from "../components/project/ProjectCard";
import AboutGallery from "./AboutGallery";
import { ProjectType } from "@/utils/types";

const SOCIAL_LINKS: { name: string; href: string; label: string }[] = [
  {
    name: "Instagram",
    href: "https://www.instagram.com/huji333",
    label: "@huji333",
  },
  {
    name: "X",
    href: "https://x.com/huji333",
    label: "@huji333",
  },
  {
    name: "GitHub",
    href: "https://github.com/huji333",
    label: "huji333",
  },
];

const INTRO_PARAGRAPHS: string[] = [
  "関西を拠点に活動するエンジニア兼フォトグラファー。デジタルとアナログの境目を探りながら、日常の景色に宿る一瞬の色彩を切り取っています。",
  "プロダクト開発では、写真や映像のワークフローを支えるツールづくりを中心に担当。ユーザー体験を意識したUI設計と、運用しやすいバックエンド設計を得意としています。",
  "このポートフォリオでは、これまでに手掛けたプロジェクトと併せて、日々撮りためている写真をアーカイブしています。",
];

const PROJECTS_API_ENABLED = process.env.NEXT_PUBLIC_PROJECTS_API_ENABLED === 'true';

const FALLBACK_PROJECTS: ProjectType[] = [
  { id: 1, title: 'フォトエッセイCMS', link: '', file: null },
  { id: 2, title: '撮影ワークフロー改善ツール', link: '', file: null },
  { id: 3, title: '展示向けWebパンフレット', link: '', file: null },
];

async function fetchProjects(): Promise<ProjectType[]> {
  if (!PROJECTS_API_ENABLED) {
    return FALLBACK_PROJECTS;
  }

  const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
  if (!baseUrl) {
    console.warn("NEXT_PUBLIC_API_BASE_URL is not set. Falling back to mock projects.");
    return FALLBACK_PROJECTS;
  }

  try {
    const response = await fetch(`${baseUrl}/projects?limit=3`, {
      next: { revalidate: 3600 },
    });

    if (!response.ok) {
      console.error("Failed to fetch projects", response.statusText);
      return FALLBACK_PROJECTS;
    }

    const data = (await response.json()) as ProjectType[];
    return data;
  } catch (error) {
    console.error("Failed to fetch projects", error);
    return FALLBACK_PROJECTS;
  }
}

export default async function Page() {
  const projects = await fetchProjects();

  return (
    <>
      <Header />
      <main className="min-h-screen bg-[#faf7f2] px-6 pb-20 pt-28">
        <section className="mx-auto w-full max-w-5xl">
          <div className="grid gap-12 lg:grid-cols-[minmax(220px,1fr)_minmax(320px,2fr)] lg:items-center">
            <div className="flex flex-col items-center gap-8 rounded-3xl bg-white/70 p-8 text-center shadow-sm lg:items-start lg:text-left">
              <div className="flex h-28 w-28 items-center justify-center rounded-full border border-black/10 bg-white text-xl font-semibold tracking-[0.3em] text-gray-700 shadow-inner">
                KF
              </div>
              <div className="space-y-3">
                <h2 className="text-sm font-medium tracking-[0.3em] text-gray-500 uppercase">Social</h2>
                <ul className="space-y-3">
                  {SOCIAL_LINKS.map((link) => (
                    <li key={link.name}>
                      <Link
                        href={link.href}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center justify-center gap-3 rounded-full border border-black/10 px-5 py-2 text-sm font-medium tracking-wide text-gray-700 transition hover:-translate-y-0.5 hover:border-black/40 hover:text-gray-900"
                      >
                        <span>{link.name}</span>
                        <span className="text-xs text-gray-500">{link.label}</span>
                      </Link>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
            <div className="space-y-6 text-left">
              <span className="text-xs tracking-[0.3em] text-gray-500 uppercase">About</span>
              <h1 className="text-3xl font-semibold text-gray-900 md:text-4xl">花毛 藤井 / Kakemu Fujii</h1>
              <div className="space-y-5 text-base leading-relaxed text-gray-700 md:text-lg">
                {INTRO_PARAGRAPHS.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section className="mx-auto mt-24 w-full max-w-5xl">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs tracking-[0.3em] text-gray-500 uppercase">Projects</span>
              <h2 className="mt-3 text-2xl font-semibold text-gray-900 md:text-3xl">最近の制作</h2>
            </div>
            <Link
              href="/projects"
              className="hidden items-center gap-2 text-sm font-medium text-gray-700 hover:text-gray-900 md:inline-flex"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
          {projects.length === 0 ? (
            <p className="mt-10 text-sm text-gray-500">表示できるプロジェクトがまだありません。</p>
          ) : (
            <div className="mt-10 grid gap-6 md:grid-cols-2 xl:grid-cols-3">
              {projects.map((project) => (
                <ProjectCard key={project.id} project={project} />
              ))}
            </div>
          )}
          <div className="mt-8 flex md:hidden">
            <Link
              href="/projects"
              className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-black/10 px-4 py-2 text-sm font-medium text-gray-700 hover:border-black/40 hover:text-gray-900"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
        </section>

        <section className="mx-auto mt-24 w-full max-w-5xl">
          <span className="text-xs tracking-[0.3em] text-gray-500 uppercase">Gallery</span>
          <h2 className="mt-3 text-2xl font-semibold text-gray-900 md:text-3xl">最近のスナップ</h2>
          <AboutGallery />
        </section>
      </main>
    </>
  );
}
