
import SiteHeader from './_components/SiteHeader';
import HeroSection from './_components/HeroSection';
import IntroSection from './_components/IntroSection';
import ProjectsSection from './_components/ProjectsSection';
import GallerySection from './_components/GallerySection';
import { ProjectType } from '@/utils/types';

const FEATURED_PROJECTS: ProjectType[] = [
  { id: 1, title: 'インターンに参加しました', link: '', file: null },
  { id: 2, title: '生態学会札幌大会で英語口頭発表賞を受賞しました', link: '', file: null },
  { id: 3, title: 'ウェブサイトを作りました', link: '', file: null },
];

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main className="snap-y snap-proximity md:snap-mandatory">
        <HeroSection />
        <IntroSection />
        <ProjectsSection projects={FEATURED_PROJECTS} />
        <GallerySection />
      </main>
    </>
  );
}
