import React, { useState, useEffect } from 'react';
import { Link, NavLink } from 'react-router-dom';
import { DownloadComponent } from '../components/atoms/DownloadComponent';
import StaggeredMenu from '../components/atoms/StaggeredMenu';

export const Navbar = () => {
    const [isScrolled, setIsScrolled] = useState(false);
    const [open, setOpen] = useState(false);

    const menuItems = [
        { label: 'PERI', ariaLabel: 'View our services', link: '/peri', target: '_self' },
        { label: 'AI', ariaLabel: 'Get in touch', link: '/ai', target: '_self' },
        { label: 'Roadmap', ariaLabel: 'Learn about us', link: '/roadmap', target: '_self' },
        { label: 'Team', ariaLabel: 'View our services', link: '/#team', target: '_self' },
        { label: 'Docs', ariaLabel: 'Go to home page', link: 'https://peridotvault.gitbook.io/docs', target: '_blank' },
    ];

    const socialItems = [
        { label: 'X', link: 'https://x.com/peridotvault' },
        { label: 'Instagram', link: 'https://www.instagram.com/peridotvault/' },
        { label: 'Discord', link: 'https://discord.com/invite/uBW4dvTR5E' },
        { label: 'Github', link: 'https://github.com/peridotvault' },
        { label: 'Telegram', link: 'https://t.me/peridotvault' },
    ];

    const base = 'hover:font-bold duration-300 hover:text-accent_primary';
    const active = 'font-bold text-accent_primary';
    const inactive = '';

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
        <header className="p-4 fixed top-0 left-0 w-full z-40">
            <div className={` transition-all duration-300 rounded-2xl flex justify-between border ${isScrolled ? 'backdrop-blur-lg border-white/10' : 'border-transparent'} max-md:hidden`}>
                <div className="w-full px-8 py-4 flex items-center justify-between">
                    <Link to={"/#"} className="text-2xl flex items-center gap-2">
                        <img src="./Logo-full.png" className="h-6" alt="PeridotVault logo" />
                        <div>
                            <span className="font-bold">Peridot</span>
                            <span>Vault</span>
                        </div>
                    </Link>

                    {/* Desktop actions */}
                    <nav className="gap-8 items-center flex text-lg">
                        {menuItems.map((item, index) => (
                            <NavLink
                                key={index}
                                to={item.link}
                                aria-label={item.label}
                                className={({ isActive }) => `${base} ${isActive ? active : inactive}`}
                                target={item.target}
                                title={item.label}
                            >
                                {item.label}
                            </NavLink>
                        ))}
                    </nav>

                    <DownloadComponent />
                </div>
            </div>

            <div className='fixed top-0 left-0 inset-0 z-50 md:hidden '>
                <StaggeredMenu
                    position="right"
                    items={menuItems}
                    socialItems={socialItems}
                    displaySocials={true}
                    displayItemNumbering={true}
                    menuButtonColor="#fff"
                    openMenuButtonColor="#000"
                    changeMenuColorOnOpen={true}
                    colors={['#90EE90', '#4D8A6A']}
                    accentColor="#4D8A6A"
                    onMenuOpen={() => console.log('Menu opened')}
                    onMenuClose={() => console.log('Menu closed')}
                />
            </div>
        </header>
    );
};
