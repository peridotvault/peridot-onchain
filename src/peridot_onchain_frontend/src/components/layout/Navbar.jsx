import React from 'react';

export const Navbar = () => {
    return (
        <nav className='fixed top-0 left-0 w-full z-30 transition-colors duration-75 backdrop-blur-lg bg-background_primary_opacity'>
            <div className="flex justify-center">
                <div className="container px-8 py-8 flex items-center justify-between">
                    <img
                        src="./logo/white-text-secondary.png"
                        className='h-8'
                        alt=""
                        data-white-src="./logo/white-text-secondary.png"
                        data-dark-src="./logo/black-text-secondary.png"
                    />
                    {/* actions  */}
                    <div className="flex gap-8 items-center">
                        <a href="">About</a>
                        <a href="">Team</a>
                        <a href="">Whitepaper</a>
                        <a href="" className='bg-accent_secondary py-3 px-8 rounded-xl font-bold'>Open App</a>
                    </div>
                </div>
            </div>
        </nav>
    );
};