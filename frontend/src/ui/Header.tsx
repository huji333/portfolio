'use client';

import Link from 'next/link';
import Logo from '@/app/assets/Logo';
import MobileMenu from './MobileMenu';
import type { HeaderStyles } from './headerStyles';
import { HEADER_STYLE_PRESETS } from './headerStyles';

export type NavItem = {
  label: string;
  href: string;
};

type HeaderProps = {
  styles?: HeaderStyles;
};

const NAV_ITEMS: NavItem[] = [
  { label: 'ABOUT', href: '/#about' },
  { label: 'GALLERY', href: '/gallery' },
  { label: 'PROJECTS', href: '/projects' },
  { label: 'CONTACT', href: '/contact' },
];

const BASE_HEADER_CLASS = 'fixed top-0 left-0 right-0 z-50 transition-colors duration-300';

export default function Header({ styles = HEADER_STYLE_PRESETS.solid }: HeaderProps) {
  return (
    <header className={`${BASE_HEADER_CLASS} ${styles.header}`}>
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-5 py-4 md:px-6 lg:px-8">
        <Link href="/" className="flex items-center" aria-label="Go to home">
          <Logo className="h-6 w-auto fill-current" aria-label="Kakemu Fujii" role="img" />
        </Link>

        <nav className="relative">
          <ul className="hidden items-center gap-6 text-sm font-medium md:flex">
            {NAV_ITEMS.map(({ label, href }) => (
              <li key={label}>
                <Link href={href} className={`group relative transition-colors ${styles.linkHover}`}>
                  {label}
                  <span className="pointer-events-none absolute left-0 -bottom-1 block h-px w-0 bg-current transition-all duration-300 ease-in-out group-hover:w-full" />
                </Link>
              </li>
            ))}
          </ul>

          <MobileMenu navItems={NAV_ITEMS} styles={styles} />
        </nav>
      </div>
    </header>
  );
}
