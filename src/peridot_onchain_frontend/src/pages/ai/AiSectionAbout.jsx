import React from 'react'

export const AiSectionAbout = () => {
    return (
        <section id='gaming_with_ai' className='py-24 max-md:py-10 flex items-center w-full max-w-[1200px] px-8 gap-8 max-md:flex-col'>
            <div className="w-full max-md:aspect-video overflow-hidden rounded-3xl aspect-[4/3]">
                <img src="./assets/views/ai/recommendation.gif" draggable={false} className='bg-background_secondary w-full h-full object-cover' alt="" />
            </div>
            <div className="w-full flex flex-col gap-4  max-md:gap-2">
                <h2 className='text-xl bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent max-md:text-lg'>Reimagining Gaming with AI</h2>
                <p className='text-3xl max-md:text-2xl'>Our AI isn’t just a feature — it’s the heart of PeridotVault. Discover games that fit your style, connect with an intelligent assistant, and enjoy a safe community.</p>
            </div>
        </section>
    )
}
