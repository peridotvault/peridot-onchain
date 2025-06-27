import React from 'react';
import { Outlet } from 'react-router-dom';
import { Header } from './Header';
import { Footer } from './Footer';

export const MainLayout = () => {

    return (
        <main className='flex flex-col w-full overflow-hidden min-h-screen justify-between text-lg max-lg:text-base'>
            <Header />
            <Outlet />
            <Footer />
        </main>
    );
}