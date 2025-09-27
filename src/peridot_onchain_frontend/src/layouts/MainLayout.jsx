import React from 'react';
import { Outlet, useMatches } from 'react-router-dom';
import { Navbar } from './Navbar';
import { Footer } from './Footer';
import ScrollToHash from '../components/atoms/ScrollToHash';
import { Music } from './Music';

export const MainLayout = () => {
    const matches = useMatches();
    const noFooter = matches.some(m => m.handle?.noFooter);
    return (
        <main className='flex flex-col w-full overflow-hidden min-h-screen justify-between'>
            <ScrollToHash />
            <Navbar />
            <Outlet />
            <Music />
            {!noFooter && <Footer />}
        </main>
    );
}