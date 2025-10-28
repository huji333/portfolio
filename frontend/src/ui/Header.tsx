import Link from 'next/link';
import Logo from '@/app/assets/logo.svg';

export type NavItem = {
  label: string;
  href: string;
};

export type HeaderStyles = {
  header: string;
  linkHover: string;
  menuButton: string;
  mobileMenu: string;
};

type HeaderProps = {
  isMenuOpen: boolean;
  onToggleMenu: () => void;
  onCloseMenu: () => void;
  styles: HeaderStyles;
};

export const HEADER_STYLE_PRESETS: Record<'light' | 'solid', HeaderStyles> = {
  light: {
    header: 'border-b border-transparent bg-transparent text-white',
    linkHover: 'hover:text-white/80',
    menuButton: 'border border-white/40 text-white',
    mobileMenu: 'border-white/20 bg-white/10 text-white backdrop-blur',
  },
  solid: {
    header: 'border-b border-foreground/10 bg-base-light/95 text-foreground backdrop-blur',
    linkHover: 'hover:text-accent',
    menuButton: 'border border-foreground/15 text-foreground',
    mobileMenu: 'border-foreground/10 bg-base-light text-foreground',
  },
};

const NAV_ITEMS: NavItem[] = [
  { label: 'ABOUT', href: '/#about' },
  { label: 'GALLERY', href: '/gallery' },
  { label: 'PROJECTS', href: '/projects' },
  { label: 'CONTACT', href: '/contact' },
];

const BASE_HEADER_CLASS = 'fixed top-0 left-0 right-0 z-50 transition-colors duration-300';

export default function Header({ isMenuOpen, onToggleMenu, onCloseMenu, styles }: HeaderProps) {
  return (
    <header className={`${BASE_HEADER_CLASS} ${styles.header}`}>
      <div className="mx-auto flex w-full max-w-6xl items-center justify-between px-5 py-4 md:px-6 lg:px-8">
        <Link
          href="/"
          className="flex items-center"
          onClick={onCloseMenu}
          aria-label="Go to home"
        >
          <Logo className="h-6 w-auto fill-current" alt="Kakemu Fujii" />
        </Link>

        <nav className="relative">
          <ul className="hidden items-center gap-6 text-sm font-medium md:flex">
            {NAV_ITEMS.map(({ label, href }) => (
              <li key={label}>
                <Link
                  href={href}
                  onClick={onCloseMenu}
                  className={`group relative transition-colors ${styles.linkHover}`}
                >
                  {label}
                  <span className="pointer-events-none absolute left-0 -bottom-1 block h-[1px] w-0 bg-current transition-all duration-300 ease-in-out group-hover:w-full" />
                </Link>
              </li>
            ))}
          </ul>

          <button
            type="button"
            className={`flex h-10 w-10 items-center justify-center rounded-full text-lg transition md:hidden ${styles.menuButton}`}
            onClick={onToggleMenu}
            aria-label="Toggle navigation"
            aria-expanded={isMenuOpen}
          >
            {'☰'}
          </button>

          {isMenuOpen && (
            <ul className={`absolute right-0 mt-3 flex w-52 flex-col gap-4 rounded-xl border p-5 text-sm font-medium shadow-xl md:hidden ${styles.mobileMenu}`}>
              {NAV_ITEMS.map(({ label, href }) => (
                <li key={label}>
                  <Link href={href} onClick={onCloseMenu}>
                    {label}
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </nav>
      </div>
    </header>
  );
}
