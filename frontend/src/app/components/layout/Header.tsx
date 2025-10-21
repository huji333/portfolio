'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import Logo from '../../assets/logo.svg';

type HeaderProps = {
  isIndexPage?: boolean;
  heroTone?: 'light' | 'dark';
};

const Header: React.FC<HeaderProps> = ({ isIndexPage = false, heroTone = 'light' }) => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => setIsOpen((prev) => !prev);

  const positionClass = isIndexPage ? 'fixed' : 'sticky';
  const isFrosted = heroTone === 'dark';
  const baseStyle = isIndexPage
    ? isFrosted
      ? 'bg-base-light/95 backdrop-blur-sm shadow-sm'
      : 'bg-transparent'
    : isFrosted
      ? 'bg-base-light/95 backdrop-blur-sm shadow-sm'
      : 'bg-[#faf7f2]';
  const textColorClass = isIndexPage
    ? isFrosted
      ? 'text-black'
      : 'text-black md:text-white'
    : 'text-black';
  const headerStyle = `${positionClass} top-0 z-50 w-full transition-colors duration-300 ${baseStyle} ${textColorClass}`;
  const logoStyle = isIndexPage
    ? isFrosted
      ? 'fill-black'
      : 'fill-black md:fill-white'
    : 'fill-black';

  const mobileMenuStyle = isFrosted
    ? 'bg-base-light text-black shadow-md'
    : isIndexPage
      ? 'bg-white/90 text-black backdrop-blur'
      : 'bg-[#faf7f2] text-black';

  const aboutHref = isIndexPage ? '#about' : '/#about';
  const navItems = [
    { label: 'ABOUT', href: aboutHref },
    { label: 'GALLERY', href: '/gallery' },
    { label: 'PROJECTS', href: '/projects' },
    { label: 'CONTACT', href: '/contact' },
  ];

  return (
    <header className={headerStyle}>
      <div className="flex w-full items-center justify-between px-6 py-8">
        <Link href="/" className="flex items-center">
          <Logo className={`h-6 w-auto ${logoStyle}`} alt="Kakemu Fujii" />
        </Link>

        <nav>
          <ul className="hidden items-center space-x-8 md:flex">
            {navItems.map(({ label, href }) => (
              <li key={label}>
                <Link
                  href={href}
                  className="relative text-sm font-medium group"
                >
                  {label}
                  <span className="absolute left-1/2 -bottom-1 h-[1px] w-0 bg-current transition-all duration-300 ease-in-out group-hover:left-0 group-hover:w-full" />
                </Link>
              </li>
            ))}
          </ul>

          <button
            className="text-xl md:hidden"
            onClick={toggleMenu}
            aria-label="Toggle Menu"
          >
            {'\u2630'}
          </button>
          {isOpen && (
            <ul
              className={`absolute left-0 top-full flex w-full flex-col space-y-4 p-4 md:hidden ${mobileMenuStyle}`}
            >
              {navItems.map(({ label, href }) => (
                <li key={label}>
                  <Link href={href} className="text-base font-medium" onClick={() => setIsOpen(false)}>
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
};

export default Header;
