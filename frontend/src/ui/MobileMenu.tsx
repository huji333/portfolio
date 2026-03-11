'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import type { NavItem } from './Header';
import type { HeaderStyles } from './headerStyles';

type MobileMenuProps = {
  navItems: NavItem[];
  styles: HeaderStyles;
};

export default function MobileMenu({ navItems, styles }: MobileMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    setIsOpen(false);
  }, [pathname]);

  const toggleMenu = () => setIsOpen((prev) => !prev);
  const closeMenu = () => setIsOpen(false);

  return (
    <>
      <button
        type="button"
        className={`flex h-10 w-10 items-center justify-center rounded-full text-lg transition md:hidden ${styles.menuButton}`}
        onClick={toggleMenu}
        aria-label="Toggle navigation"
        aria-expanded={isOpen}
      >
        {'☰'}
      </button>

      {isOpen && (
        <ul
          className={`absolute right-0 mt-3 flex w-52 flex-col gap-4 rounded-xl border p-5 text-sm font-medium shadow-xl md:hidden ${styles.mobileMenu}`}
        >
          {navItems.map(({ label, href }) => (
            <li key={label}>
              <Link href={href} onClick={closeMenu}>
                {label}
              </Link>
            </li>
          ))}
        </ul>
      )}
    </>
  );
}
