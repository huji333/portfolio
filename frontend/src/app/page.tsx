
import SiteHeader from './_components/SiteHeader';
import HeroSection from './_components/HeroSection';
import IntroSection from './_components/IntroSection';
import ProjectsSection from './_components/ProjectsSection';
import GallerySection from './_components/GallerySection';
import { ProjectType } from '@/utils/types';

export default function HomePage() {
  return (
    <>
      <SiteHeader />
      <main className="snap-y snap-proximity md:snap-mandatory">
        <HeroSection />
        <IntroSection />
        <ProjectsSection projects={[]} />
        <GallerySection />
      </main>
    </>
  );
}
