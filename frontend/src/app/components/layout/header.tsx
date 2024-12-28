'use client'

import React, { useState } from 'react';

const Header: React.FC = () => {
    const [isOpen, setIsOpen] = useState(false);

    const toggleMenu = () => {
        setIsOpen(!isOpen);
    };

    return (
        <header className={`fixed top-0 w-full z-50 transition-all`}>
            <div className="max-w-7xl mx-auto flex justify-between items-center px-4 py-2">
                {/* ロゴ */}
                <div>

                </div>

                {/* ナビゲーション */}
                <nav>
                    {/* デスクトップメニュー */}
                    <ul className="hidden md:flex space-x-6">
                        <li><a href="#home" className="hover:underline">Home</a></li>
                        <li><a href="#about" className="hover:underline">About</a></li>
                        <li><a href="#services" className="hover:underline">Services</a></li>
                        <li><a href="#contact" className="hover:underline">Contact</a></li>
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
                        <ul className="absolute top-12 left-0 w-full bg-gray-800 text-white flex flex-col space-y-4 p-4 md:hidden">
                            <li><a href="#home" className="hover:underline">Home</a></li>
                            <li><a href="#about" className="hover:underline">About</a></li>
                            <li><a href="#services" className="hover:underline">Services</a></li>
                            <li><a href="#contact" className="hover:underline">Contact</a></li>
                        </ul>
                    )}
                </nav>
            </div>
        </header>
    );
};

export default Header;
