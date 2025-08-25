import React from 'react';
import { Outlet } from 'react-router-dom';
import { Navbar } from './Navbar';
import { Footer } from './Footer';
import ScrollToHash from '../components/atoms/ScrollToHash';
import { Music } from './Music';

export const MainLayout = () => {
    return (
        <main className='flex flex-col w-full overflow-hidden min-h-screen justify-between'>
            <ScrollToHash />
            <Navbar />
            <Outlet />
            <Music />
            <Footer />
        </main>
    );
}