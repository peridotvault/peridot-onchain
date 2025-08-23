import React, { useState, useEffect } from 'react';
import StarBorder from '../components/atoms/StarBorder';
import { Link } from 'react-router-dom';

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
                    <Link to={"/#"} className='text-2xl flex items-center gap-2'>
                        <img
                            src="./Logo-full.png"
                            className='h-6'
                            alt=""
                        />
                        <div className="">
                            <span className='font-bold'>Peridot</span>
                            <span >Vault</span>
                        </div>
                    </Link>
                    {/* actions  */}
                    <div className="flex gap-8 items-center max-md:hidden">
                        <a href="/#about">About</a>
                        <a href="/roadmap">Roadmap</a>
                        <a href="/#team">Team</a>
                        <a href="/ai">AI</a>
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