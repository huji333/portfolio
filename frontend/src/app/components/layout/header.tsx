'use client'

import React, { useState } from 'react';
import Logo from '../../assets/logo.svg';

const Header: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleMenu = () => {
    setIsOpen(!isOpen);
  };

  return (
    <header className="fixed top-0 w-full z-50 transition-all">
      <div className="w-full flex justify-between items-center px-6 py-8">
        {/* ロゴ */}
        <a href="/" className="flex items-center">
          <Logo className="h-6 w-auto fill-black md:hidden" alt="Kakemu Fujii" />
          <Logo className="h-6 w-auto hidden md:block" fill="white" alt="Kakemu Fujii" />
        </a>

        {/* ナビゲーション */}
        <nav>
          {/* デスクトップメニュー */}
          <ul className="hidden md:flex items-center space-x-8">
            {['ABOUT', 'GALLERY', 'PROJECTS', 'CONTACT'].map((item) => (
              <li key={item}>
                <a
                  href={`#${item.toLowerCase()}`}
                  className="font-medium text-sm text-white relative link-underline-animation"
                >
                  {item}
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
            ☰
          </button>
          {isOpen && (
            <ul className="absolute top-18 left-3 w-full text-white flex flex-col space-y-4 p-4 md:hidden backdrop-blur-sm">
              {['ABOUT', 'GALLERY', 'PROJECTS', 'CONTACT'].map((item) => (
                <li key={item}>
                  <a
                    href={`#${item.toLowerCase()}`}
                    className="font-medium text-base text-black"
                  >
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          )}
        </nav>
      </div>

      <style jsx>{`
        /* 下線アニメーション */
        .link-underline-animation {
          position: relative;
        }
        .link-underline-animation::after {
          content: "";
          position: absolute;
          height: 1px;
          background: currentColor;
          width: 0;
          left: 50%;
          bottom: -4px;
          transition: width 0.3s ease, left 0.3s ease;
        }
        .link-underline-animation:hover::after {
          width: 100%;
          left: 0;
        }
      `}</style>
    </header>
  );
};

export default Header;
