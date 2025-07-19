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
        <header className={`fixed top-0 left-0 w-full z-30 transition-all duration-300 flex justify-center ${isScrolled ? 'backdrop-blur-lg' : ''}`}>
            <div className="w-full px-12 py-8 flex items-center justify-between">
                <a href="/#" className='text-2xl'>
                    <span className='font-bold'>Peridot</span>
                    <span >Vault</span>
                    {/* <img
                        src="./logo/white-text-secondary.png"
                        className='h-8 max-md:h-6'
                        alt=""
                        data-white-src="./logo/white-text-secondary.png"
                        data-dark-src="./logo/black-text-secondary.png"
                    /> */}
                </a>
                {/* actions  */}
                <div className="flex gap-8 items-center max-md:hidden">
                    <a href="/#about">About</a>
                    <a href="/#roadmap">Roadmap</a>
                    <a href="/#team">Team</a>
                    <a href="/#" className='bg-accent_secondary py-3 px-8 rounded-xl font-bold'>Download</a>
                </div>
            </div>
        </header>
    );
};