import React, { useState, useEffect } from 'react';
import StarBorder from '../components/atoms/StarBorder';

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
        <div className="p-4 fixed  top-0 left-0 w-full z-30">
            <header className={`transition-all duration-300 rounded-2xl flex justify-center border border-transparent ${isScrolled ? 'backdrop-blur-lg border-white/10' : ''}`}>
                <div className="w-full px-8 py-6 flex items-center justify-between">
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
                        <a href="/#" >
                            <StarBorder
                                as="button"
                                className=""
                                color="#90EE90"
                                speed="2s"
                            >
                                Download
                            </StarBorder>
                        </a>
                    </div>
                </div>
            </header>
        </div>
    );
};