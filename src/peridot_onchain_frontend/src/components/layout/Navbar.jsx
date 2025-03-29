import React, { useState, useEffect } from 'react';

export const Navbar = () => {
    const [isScrolled, setIsScrolled] = useState(false);

    const handleScroll = () => {
        if (window.scrollY > 0) {
            setIsScrolled(true);
        } else {
            setIsScrolled(false);
        }
    };

    useEffect(() => {
        window.addEventListener('scroll', handleScroll);
        return () => {
            window.removeEventListener('scroll', handleScroll);
        };
    }, []);
    return (
        <nav className={`fixed top-0 left-0 w-full z-30 transition-all duration-300 ${isScrolled ? 'backdrop-blur-lg' : ''}`}>
            <div className="flex justify-center">
                <div className="container px-8 py-6 flex items-center justify-between">
                    <img
                        src="./logo/white-text-secondary.png"
                        className='h-8'
                        alt=""
                        data-white-src="./logo/white-text-secondary.png"
                        data-dark-src="./logo/black-text-secondary.png"
                    />
                    {/* actions  */}
                    <div className="flex gap-8 items-center">
                        <a href="/#about">About</a>
                        <a href="/#team">Team</a>
                        <a href="/#roadmap">Roadmap</a>
                        <a href="/#" className='bg-accent_secondary py-3 px-8 rounded-xl font-bold'>Download</a>
                    </div>
                </div>
            </div>
        </nav>
    );
};