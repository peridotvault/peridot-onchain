import React from 'react'
import GlassComponent from '../../components/atoms/GlassComponent'
import { ContainerGlass } from '../../components/molecules/ContainerGlass'

export const AiSectionCompanion = () => {

    const list = [
        {
            title: "Real-time Tactical Support",
            description: "Get instant strategic tips while you play, tailored to your current in-game situation",
        },
        {
            title: "Learns and Adapts Your Playstyle",
            description: "Receive intelligent prompts based on what’s happening in your game right when you need them.",
        }, {

            title: "Context-aware Suggestions",
            description: "The more you play, the smarter it gets. Evolving to fit your unique gaming habits.",
        }
    ]

    return (
        <section className='max-w-[1200px] px-8 max-md:px-4 py-24 max-md:py-10 w-full'>
            <div className="w-full p-16 max-md:p-8 flex flex-col gap-16  max-md:gap-8 rounded-2xl border border-white/10">
                {/* title  */}
                <div className="flex max-md:flex-col items-center justify-between gap-16 max-md:gap-8">
                    <div className="w-1/2 max-md:w-full flex flex-col gap-6 max-md:gap-4">
                        <div className="bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent flex flex-col gap-2">
                            <span className='uppercase text-base max-md:text-sm'>ARTIFICIAL INTELLIGENCE</span>
                            <h2 className='text-4xl font-bold max-md:text-3xl'>AI Companion: Your
                                In-Game Teammate</h2>
                        </div>
                        <p className='max-md:text-base'>The AI Companion in Peridot offers real-time support, actionable strategies, and interactive feedback tailored to your gameplay. Whether you’re exploring new missions, facing boss fights, or managing resources, your AI assistant is always a step ahead — ready to guide, suggest, and react based on in-game context.</p>
                    </div>
                    <div className="w-1/2 rounded-2xl overflow-hidden aspect-video max-md:w-full max-md:aspect-video">
                        <img src="./assets/views/landing/ai.gif" draggable={false} alt="" className='w-full h-full object-cover' />
                    </div>
                </div>
                {/* content feature  */}
                <div className="grid grid-cols-3 max-lg:grid-cols-2 max-md:grid-cols-1 gap-8">
                    {list.map((item, idx) => (
                        <GlassComponent key={idx} className="aspect-[4/3] max-md:aspect-video border rounded-2xl flex flex-col gap-8 py-8 max-md:py-6 max-md:gap-6 bg-white/5 backdrop-blur-md border-white/10 hover:bg-accent_secondary duration-300">
                            <h3 className='text-3xl px-8 font-bold max-md:text-2xl'>{item.title}</h3>
                            <p className='px-8 max-md:text-base'>{item.description}</p>
                        </GlassComponent>
                    ))}
                </div>
            </div>
        </section>
    )
}
