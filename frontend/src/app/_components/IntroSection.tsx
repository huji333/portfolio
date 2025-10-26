import Image from 'next/image';
import Link from 'next/link';
import type { IconType } from 'react-icons';
import { FaGithub, FaInstagram } from 'react-icons/fa';
import { FaXTwitter } from 'react-icons/fa6';

const SOCIAL_LINKS: { href: string; label: string; icon: IconType }[] = [
  {
    href: 'https://www.instagram.com/fuji_sn4p',
    label: '@fuji_sn4p',
    icon: FaInstagram,
  },
  {
    href: 'https://x.com/k4kemu',
    label: '@k4kemu',
    icon: FaXTwitter,
  },
  {
    href: 'https://github.com/huji333',
    label: 'huji333',
    icon: FaGithub,
  },
];

const INTRO_PARAGRAPHS: string[] = [
  '京都大学理学研究科生物科学専攻 M1',
  '昆虫が葉につける食痕についての研究。その傍でweb開発と写真撮影をしています。',
];

export default function IntroSection() {
  return (
    <section
      id="about"
      className="bg-base-light px-6 py-20 md:py-24 snap-ignore scroll-mt-24"
      aria-labelledby="about-heading"
    >
      <div className="mx-auto w-full max-w-5xl">
        <div className="mx-auto flex w-full flex-col gap-12 md:flex-row md:items-start">
          <div className="flex flex-col items-start gap-4 md:w-[35%]">
            <div className="relative h-48 w-48 overflow-hidden rounded-full border border-accent-light/60 bg-accent-light shadow-inner md:h-60 md:w-60">
              <Image
                src="/icon_kakemu.jpg"
                alt="Kakemu Fujii"
                fill
                sizes="(min-width: 1024px) 240px, 192px"
                className="object-cover"
                priority
              />
            </div>
          </div>
          <div className="space-y-7 md:w-[55%]">
            <div className="space-y-5">
              <h2 id="about-heading" className="text-3xl font-semibold text-foreground md:text-4xl">
                Kakemu Fujii
              </h2>
              <div className="space-y-4 text-base leading-relaxed text-foreground md:text-lg">
                {INTRO_PARAGRAPHS.map((paragraph) => (
                  <p key={paragraph}>{paragraph}</p>
                ))}
              </div>
            </div>
            <div className="flex flex-wrap gap-3">
              {SOCIAL_LINKS.map(({ href, label, icon: Icon }) => (
                <Link
                  key={label}
                  href={href}
                  target="_blank"
                  rel="noreferrer"
                  className="inline-flex items-center gap-2 rounded-full border border-foreground/10 bg-base px-4 py-2 text-sm font-medium text-foreground transition hover:-translate-y-0.5 hover:border-accent hover:text-accent"
                >
                  <span className="flex h-8 w-8 items-center justify-center rounded-full bg-accent-light/40 text-accent">
                    <Icon aria-hidden className="h-4 w-4" />
                  </span>
                  <span>{label}</span>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
