import React from 'react'
import { CarouselCard } from '../../components/molecules/CarouselCard';
import AnimatedContent from '../../components/animations/AnimatedContent';

export const Section3 = () => {


    return (
        <AnimatedContent>
            <section id='about' className='max-w-[1200px] flex max-md:flex-col justify-between px-8 py-24 max-md:py-10 gap-10 w-full overflow-hidden'>
                <div className="max-w-[35rem] flex flex-col items-start gap-5">
                    <p className='bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent max-md:text-sm'>Gaming isn't just a hobby</p>
                    <h2 className='text-4xl font-bold max-md:text-3xl'>Elevate Your Lifestyle with the Vault of Games</h2>
                    <p className='text-xl max-md:text-base'>Blockchain Gaming Platform that allows Gamers to Buy, Download, and Play their favorite Games.</p>
                </div>
                <CarouselCard />
            </section>
        </AnimatedContent>
    )
}
