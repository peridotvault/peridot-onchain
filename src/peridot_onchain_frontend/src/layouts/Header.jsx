import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';

export const Header = () => {
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
            <div className="max-w-[1350px] w-full px-8 py-6 flex items-center justify-between">
                <Link to={"/#"} className='text-3xl'>
                    <span className='font-bold'>Peridot</span>
                    <span>Vault</span>
                    {/* <img
                        src="./logo/white-text-secondary.png"
                        className='h-8 max-md:h-6'
                        alt=""
                        data-white-src="./logo/white-text-secondary.png"
                        data-dark-src="./logo/black-text-secondary.png"
                    /> */}
                </Link>
                {/* actions  */}
                <div className="flex gap-8 items-center max-md:hidden">
                    <Link to={"/#about"}>About</Link>
                    <Link to={"/#roadmap"}>Roadmap</Link>
                    <Link to={"/#team"}>Team</Link>
                    <Link to={"/#"} className='bg-accent_secondary py-3 px-8 rounded-xl font-bold'>Download</Link>
                </div>
            </div>
        </header>
    );
};