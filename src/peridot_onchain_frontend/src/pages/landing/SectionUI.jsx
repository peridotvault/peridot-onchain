import React from 'react'

export const SectionUI = () => {
    return (
        <section id='product' className='max-w-[1200px] flex flex-col items-center gap-2 relative pt-24 max-md:py-10 pb-12 '>
            <div className="flex flex-col items-center text-center max-md:text-start gap-6 px-8">
                <h2 className='bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent text-5xl font-bold max-md:text-3xl w-full duration-300'>Gaming, Evolved with AI and Web3</h2>
                <p className='w-4/5 max-md:w-full duration-300 max-md:text-base'>PeridotVault is more than just a platform, it’s where advanced AI meets decentralized technology to create a smarter, more connected gaming experience for players and developers alike</p>
            </div>


            <div className="relative">
                <div className="absolute bg-gradient-radial from-accent_primary/40 via-transparent top-0 left-0 -translate-y-1/4 -z-10 w-full h-full"></div>
                <img src="./assets/views/landing/mockup-home.webp" className='object-contain' draggable={false} alt="" />
                <div className="w-full h-2/3 bg-gradient-to-t from-background_primary absolute bottom-[5%] left-0"></div>
            </div>
        </section>
    )
}
