import React from 'react'

export const AiSectionAbout = () => {
    return (
        <section className='flex justify-center w-full py-24'>
            <div className="flex items-center w-full max-w-[1200px] px-8 gap-8">
                <div className="w-full overflow-hidden rounded-3xl aspect-[4/3]">
                    <img src="" className='bg-background_secondary w-full h-full' alt="" />
                </div>
                <div className="w-full flex flex-col gap-4">
                    <h2 className='text-xl bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent'>Reimagining Gaming with AI</h2>
                    <p className='text-3xl'>From intelligent game discovery to real-time in-game assistance, AI is deeply embedded in Peridot’s ecosystem. Whether you’re browsing the Game Vault, planning your next session, or managing your assets, our AI technology works quietly behind the scenes to create a seamless, adaptive experience.</p>
                </div>
            </div>
        </section>
    )
}
