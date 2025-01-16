import React from 'react';
import { Outlet } from 'react-router-dom';
import { Navbar } from './Navbar';
import { Footer } from './Footer';
import { SmoothScroll } from '../animations/gsap';

export const MainLayout = () => {

    return (
        <main>
            <Navbar />
            <SmoothScroll >
                <div data-scroll-section>
                    <Outlet />
                    <Footer />
                </div>
            </SmoothScroll>
        </main>
    );
}