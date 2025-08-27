import React from 'react'
import { DownloadComponent } from '../../components/atoms/DownloadComponent';

export const Section1 = () => {


    return (
        <section className="flex w-full p-4">
            <div className="relative w-full flex justify-center overflow-hidden rounded-2xl">
                <div className="max-w-[1200px] flex justify-center items-center px-8 h-[80dvh] ">
                    <div className="w-full text-center flex flex-col gap-6 max-md:gap-4 ">
                        <div className="mb-5 ">
                            <label className='shadow-xl shadow-accent_primary/30 py-2 px-4 rounded-lg ring-1 ring-accent_primary/30 text-base max-md:text-sm'>Prototype Version 0.0.0</label>
                        </div>
                        <h1 className='text-6xl font-bold max-md:text-3xl'>Intelligent Decentralized Gaming</h1>
                        <p className='text-xl max-w-[50rem] max-md:text-base'>Your next gaming era starts here personalized by AI and powered by blockchain. PeridotVault gives you control, simplicity, and freedom.</p>
                        <div className="flex justify-center items-center gap-6">
                            <DownloadComponent />
                        </div>
                    </div>
                </div>

                <video
                    autoPlay
                    draggable={false}
                    muted
                    loop
                    className="absolute -z-20 w-full h-full top-0 left-0 object-cover"
                >
                    <source src="https://res.cloudinary.com/dcf3oktvs/video/upload/v1743225301/hb1b0kqgmkjlpy9qglzy.mp4" />
                </video>

                <div className="w-full h-full bg-background_primary opacity-30 absolute bottom-0 -z-10"></div>
            </div>
        </section>
    )
}
