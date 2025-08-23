import React from 'react'
import GlassComponent from '../../components/atoms/GlassComponent'
import { Link } from 'react-router-dom'

export const SectionAI = () => {
    return (
        <section className='max-w-[1200px] px-8 max-md:px-4 py-24 max-md:py-10 w-full'>
            <GlassComponent
                className="w-full p-16 max-md:p-8 flex gap-12 items-center justify-between rounded-2xl max-lg:flex-col"
            >
                <div className="w-1/2 max-lg:w-full flex flex-col gap-6">
                    <div className="bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent">
                        <span className='uppercase text-base max-md:text-sm'>Feature</span>
                        <h2 className='text-4xl font-bold max-md:text-3xl'>Smarter Play, Powered by AI</h2>
                    </div>
                    <p className='max-md:text-base'>PeridotVault's AI curates games just for you, assists your journey, and keeps communities safe — making every play smarter and more personal.</p>
                    <div className="flex">
                        <Link to={"/ai"} className='bg-accent_secondary p-3 px-6 rounded-xl max-md:text-base'>Learn More Our AI Features</Link>
                    </div>
                </div>
                <div className="w-1/2 aspect-[4/3] max-lg:w-full max-lg:aspect-video  rounded-xl overflow-hidden bg-background_primary">
                    <img src="./assets/views/landing/ai.gif" alt="" className='w-full h-full object-cover opacity-90' draggable={false} />
                </div>
            </GlassComponent>
        </section>
    )
}
