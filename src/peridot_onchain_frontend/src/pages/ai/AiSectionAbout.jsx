import React from 'react'

export const AiSectionAbout = () => {
    return (
        <section className='py-24 flex items-center w-full max-w-[1200px] px-8 gap-8 max-md:flex-col'>
            <div className="w-full  max-md:aspect-video overflow-hidden rounded-3xl aspect-[5/6] bg-green-500">
                <img src="./assets/views/ai/gaming.avif" draggable={false} className='bg-background_secondary w-full h-full object-cover opacity-80' alt="" />
            </div>
            <div className="w-full flex flex-col gap-4">
                <h2 className='text-xl bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent'>Reimagining Gaming with AI</h2>
                <p className='text-3xl'>Our AI isn’t just a feature — it’s the heart of PeridotVault. Discover games that fit your style, connect with an intelligent assistant, and enjoy a safe community.</p>
            </div>
        </section>
    )
}
