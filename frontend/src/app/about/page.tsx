import Header from "../components/layout/Header";
import AboutSection from "../components/about/AboutSection";

export default async function AboutPage() {
  return (
    <>
      <Header heroTone="dark" />
      <main className="min-h-screen bg-base-light px-6 pb-20 pt-28">
        <AboutSection />
      </main>
    </>
  );
}
