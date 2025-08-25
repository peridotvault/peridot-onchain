import React, { useState, useEffect } from 'react';
import StarBorder from '../components/atoms/StarBorder';
import { Link } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faBars, faXmark } from '@fortawesome/free-solid-svg-icons';
import GlassComponent from '../components/atoms/GlassComponent';

export const Navbar = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [open, setOpen] = useState(false);

    // blur background on scroll (punyamu)
    useEffect(() => {
        const onScroll = () => setIsScrolled(window.scrollY > 0);
        window.addEventListener('scroll', onScroll);
        return () => window.removeEventListener('scroll', onScroll);
    }, []);

    // lock body scroll saat drawer terbuka
    useEffect(() => {
        document.body.classList.toggle('overflow-hidden', open);
        return () => document.body.classList.remove('overflow-hidden');
    }, [open]);

    // close dengan Escape
    useEffect(() => {
        const onKey = (e) => e.key === 'Escape' && setOpen(false);
        window.addEventListener('keydown', onKey);
        return () => window.removeEventListener('keydown', onKey);
    }, []);

    return (
        <div className="p-4 fixed top-0 left-0 w-full z-40">
            <header className={` transition-all duration-300 rounded-2xl flex justify-between border ${isScrolled ? 'backdrop-blur-lg border-white/10' : 'border-transparent'}`}>
                <div className="w-full px-8 py-4 flex items-center justify-between">
                    <Link to={"/#"} className="text-2xl flex items-center gap-2">
                        <img src="./Logo-full.png" className="h-6" alt="PeridotVault logo" />
                        <div>
                            <span className="font-bold">Peridot</span>
                            <span>Vault</span>
                        </div>
                    </Link>

                    {/* Desktop actions */}
                    <nav className="hidden md:flex gap-8 items-center">
                        <Link to="/#product">Product</Link>
                        <Link to="/roadmap">Roadmap</Link>
                        <Link to="/#team">Team</Link>
                        <Link to="/ai">AI</Link>
                        <Link to="/">
                            <StarBorder as="button" color="#90EE90" speed="2s">
                                Download
                            </StarBorder>
                        </Link>
                    </nav>


                    {/* Mobile hamburger */}
                    <GlassComponent className="md:hidden rounded-lg overflow-hidden">
                        <button
                            className="inline-flex items-center justify-center hover:bg-white/5 p-4 duration-300"
                            onClick={() => setOpen(true)}
                            aria-label="Open menu"
                            aria-controls="mobile-menu"
                            aria-expanded={open}
                        >
                            <FontAwesomeIcon icon={faBars} />
                        </button>
                    </GlassComponent>
                </div>
            </header>

            {/* Mobile drawer */}
            <div className={`md:hidden fixed inset-0 z-50 ${open ? '' : 'pointer-events-none'}`}>
                {/* overlay */}
                <div
                    className={`absolute inset-0 bg-black/50 transition-opacity ${open ? 'opacity-100' : 'opacity-0'}`}
                    onClick={() => setOpen(false)}
                />
                {/* panel */}
                <nav
                    id="mobile-menu"
                    className={`absolute top-0 right-0 h-full w-[80%] max-w-sm bg-background_primary border-l border-white/10 p-6 transition-transform duration-300 ${open ? 'translate-x-0' : 'translate-x-full'}`}
                    role="dialog"
                    aria-modal="true"
                >
                    <div className="flex items-center justify-between mb-6">
                        <Link to={"/#"} className="text-2xl flex items-center gap-2" onClick={() => setOpen(false)}>
                            <img src="./Logo-full.png" className="h-6" alt="PeridotVault logo" />
                            <div>
                                <span className="font-bold">Peridot</span>
                                <span>Vault</span>
                            </div>
                        </Link>
                        <button
                            className="py-2 px-4 rounded-lg border border-white/15 hover:bg-white/5"
                            onClick={() => setOpen(false)}
                            aria-label="Close menu"
                        >
                            <FontAwesomeIcon icon={faXmark} />
                        </button>
                    </div>

                    <ul className="space-y-3 text-lg">
                        <li><Link to="/#product" className="block py-2" onClick={() => setOpen(false)}>Product</Link></li>
                        <li><Link to="/roadmap" className="block py-2" onClick={() => setOpen(false)}>Roadmap</Link></li>
                        <li><Link to="/#team" className="block py-2" onClick={() => setOpen(false)}>Team</Link></li>
                        <li><Link to="/ai" className="block py-2" onClick={() => setOpen(false)}>AI</Link></li>
                    </ul>

                    <div className="mt-6">
                        <a href="/#" onClick={() => setOpen(false)}>
                            <StarBorder as="button" className="w-full" color="#90EE90" speed="2s">
                                Download
                            </StarBorder>
                        </a>
                    </div>
                </nav>
            </div>
        </div>
    );
};
