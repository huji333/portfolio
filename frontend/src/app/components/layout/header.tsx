'use client';

import React, { useState } from 'react';
import Logo from '../../assets/logo.svg';

type HeaderProps = {
  isIndexPage?: boolean;
};

const Header: React.FC<HeaderProps> = ({ isIndexPage = false }) => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => setIsOpen((prev) => !prev);

  const positionClass = isIndexPage ? 'fixed' : 'sticky';
  const baseStyle = isIndexPage
    ? 'bg-transparent text-black md:text-white'
    : 'bg-[#faf7f2] text-black';
  const logoStyle = isIndexPage
    ? 'fill-black md:fill-white'
    : 'fill-black';

  return (
    <header className={`${positionClass} top-0 w-full z-50 transition-all ${baseStyle}`}>
      <div className="w-full flex justify-between items-center px-6 py-8">
        {/* ロゴ */}
        <a href="/" className="flex items-center">
          <Logo className={`h-6 w-auto ${logoStyle}`} alt="Kakemu Fujii" />
        </a>

        {/* ナビゲーション */}
        <nav>
          {/* デスクトップメニュー */}
          <ul className="hidden md:flex items-center space-x-8">
            {['ABOUT', 'GALLERY', 'PROJECTS', 'CONTACT'].map((item) => (
              <li key={item}>
                <a
                  href={`/${item.toLowerCase()}`}
                  className="font-medium text-sm relative group"
                >
                  {item}
                  <span className="absolute left-1/2 -bottom-1 h-[1px] w-0 bg-current transition-all duration-300 ease-in-out group-hover:w-full group-hover:left-0"></span>
                </a>
              </li>
            ))}
          </ul>

          {/* モバイルメニュー */}
          <button
            className="md:hidden text-xl"
            onClick={toggleMenu}
            aria-label="Toggle Menu"
          >
            {"\u2630"}
          </button>
          {isOpen && (
            <ul className="absolute left-0 top-full w-full bg-transparent text-black flex flex-col space-y-4 p-4 md:hidden">
              {['ABOUT', 'GALLERY', 'PROJECTS', 'CONTACT'].map((item) => (
                <li key={item}>
                  <a href={`/${item.toLowerCase()}`} className="font-medium text-base">
                    {item}
                  </a>
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
