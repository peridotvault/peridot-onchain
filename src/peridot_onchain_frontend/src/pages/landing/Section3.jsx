import React, { useEffect, useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faStore, faVault, faWallet } from '@fortawesome/free-solid-svg-icons'
import { CarouselCard } from '../../components/molecules/CarouselCard';

export const Section3 = () => {


    return (
        <section id='about' className='max-w-[1200px] flex max-md:flex-col justify-between px-8 pt-48 pb-24 gap-10 w-full overflow-hidden'>
            <div className="w-[35rem] flex flex-col items-start gap-5">
                <p className='bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent'>Gaming isn't just a hobby</p>
                <p className='text-4xl font-bold'>Elevate Your Lifestyle with the Vault of Games</p>
                <p className='text-xl'>Blockchain Gaming Platform that allows Gamers to Buy, Download, and Play their favorite Games.</p>
            </div>
            <CarouselCard />
        </section>
    )
}
