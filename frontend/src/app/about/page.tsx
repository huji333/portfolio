import Image from "next/image";
import Link from "next/link";
import type { IconType } from "react-icons";
import { FaGithub, FaInstagram } from "react-icons/fa";
import { FaXTwitter } from "react-icons/fa6";
import Header from "../components/layout/Header";
import ProjectCard from "../components/project/ProjectCard";
import AboutGallery from "./AboutGallery";
import { ProjectType } from "@/utils/types";

type SocialLink = {
  href: string;
  label: string;
  icon: IconType;
};

const SOCIAL_LINKS: SocialLink[] = [
  {
    href: "https://www.instagram.com/fuji_sn4p",
    label: "@fuji_sn4p",
    icon: FaInstagram,
  },
  {
    href: "https://x.com/k4kemu",
    label: "@k4kemu",
    icon: FaXTwitter,
  },
  {
    href: "https://github.com/huji333",
    label: "huji333",
    icon: FaGithub,
  },
];

const INTRO_PARAGRAPHS: string[] = [
  "京都大学理学研究科生物科学専攻 M1",
  "昆虫が葉につける食痕についての研究。その傍でweb開発と写真撮影をしています。",
];

const PROJECTS_API_ENABLED = process.env.NEXT_PUBLIC_PROJECTS_API_ENABLED === 'true';

const FALLBACK_PROJECTS: ProjectType[] = [
  { id: 1, title: 'インターンに参加しました', link: '', file: null },
  { id: 2, title: '生態学会札幌大会で英語口頭発表賞を受賞しました', link: '', file: null },
  { id: 3, title: 'ウェブサイトを作りました', link: '', file: null },
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
      <main className="min-h-screen bg-base-light px-6 pb-20 pt-28">
        <section className="mx-auto w-full max-w-5xl">
          <div className="flex flex-col gap-12 lg:flex-row lg:items-start">
            <div className="flex flex-col items-start gap-4 text-left lg:w-[35%]">
              <span className="text-xs tracking-[0.3em] text-accent uppercase">About</span>
              <div className="relative h-52 w-52 overflow-hidden rounded-full border border-accent-light/60 bg-accent-light shadow-inner lg:h-64 lg:w-64">
                <Image
                  src="/icon_kakemu.jpg"
                  alt="Kakemu Fujii"
                  fill
                  sizes="(min-width: 1280px) 256px, (min-width: 1024px) 224px, 208px"
                  className="object-cover"
                  priority
                />
              </div>
            </div>
            <div className="space-y-7 text-left lg:w-[55%]">
              <div className="space-y-5 pt-2.5">
                <h1 className="text-3xl font-semibold text-foreground md:text-4xl">Kakemu Fujii</h1>
                <div className="space-y-5 leading-relaxed text-foreground/80 md:text-lg">
                  {INTRO_PARAGRAPHS.map((paragraph) => (
                    <p key={paragraph}>{paragraph}</p>
                  ))}
                </div>
              </div>
              <div className="space-y-4">
                <div className="flex flex-wrap gap-3">
                  {SOCIAL_LINKS.map((link) => {
                    const Icon = link.icon;

                    return (
                      <Link
                        key={link.label}
                        href={link.href}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-2 rounded-full bg-base px-3 py-2 text-sm font-medium tracking-wide text-foreground/80 transition hover:-translate-y-0.5 hover:bg-base-dark"
                      >
                        <span className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-accent-light/40 text-accent">
                          <Icon aria-hidden className="h-4 w-4" />
                        </span>
                        <span>{link.label}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="mx-auto mt-24 w-full max-w-5xl">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs tracking-[0.3em] text-accent uppercase">Projects</span>
              <h2 className="mt-3 text-2xl font-semibold text-foreground md:text-3xl">最近の制作</h2>
            </div>
            <Link
              href="/projects"
              className="hidden items-center gap-2 text-sm font-medium text-foreground/80 hover:text-accent md:inline-flex"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
          {projects.length === 0 ? (
            <p className="mt-10 text-sm text-foreground/70">表示できるプロジェクトがまだありません。</p>
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
              className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-accent-light/60 px-4 py-2 text-sm font-medium text-foreground hover:border-accent hover:text-accent"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
        </section>

        <section className="mx-auto mt-24 w-full max-w-5xl">
          <div className="flex items-center justify-between">
            <div>
              <span className="text-xs tracking-[0.3em] text-accent uppercase">Gallery</span>
              <h2 className="mt-3 text-2xl font-semibold text-foreground md:text-3xl">作品集</h2>
            </div>
            <Link
              href="/gallery"
              className="hidden items-center gap-2 text-sm font-medium text-foreground/80 hover:text-accent md:inline-flex"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
          <AboutGallery />
          <div className="mt-8 flex md:hidden">
            <Link
              href="/gallery"
              className="inline-flex w-full items-center justify-center gap-2 rounded-full border border-accent-light/60 px-4 py-2 text-sm font-medium text-foreground hover:border-accent hover:text-accent"
            >
              もっと見る
              <span aria-hidden>→</span>
            </Link>
          </div>
        </section>
      </main>
    </>
  );
}
