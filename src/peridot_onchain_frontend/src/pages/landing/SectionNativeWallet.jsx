import React from 'react'
import { faWallet } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'
import AnimatedContent from '../../components/animations/AnimatedContent'

export const SectionNativeWallet = () => {
    const list = [
        {
            title: "Built for Gamers",
            description: "A wallet that works like magic—effortless, integrated, and ready when you are.",
            image: "./assets/views/landing/build-for-gamers.webp",
        },
        {
            title: "Secure & Self-Custodial",
            description: "Your assets are yours—no banks, no middlemen, just pure control.",
            image: "./assets/views/landing/secure.webp",
        },
    ]
    return (
        <AnimatedContent>
            <section className='max-w-[1200px] px-8 max-md:px-4 py-24 max-md:py-10 w-full '>

                <div className="flex flex-col gap-12 max-md:gap-8 p-16 max-md:p-8 border border-background_disabled rounded-2xl duration-300">
                    <FeatureHeader icon={faWallet} title={"Native Wallet"} description={"Meet the wallet that feels invisible—always there, always secure. Complete control of your digital assets, without the complexity."} />

                    {/* contents  */}
                    <div className="grid grid-cols-2 max-lg:grid-cols-1 gap-8 bh">
                        {list.map((item, idx) => (
                            <div className="aspect-[4/3] max-lg:aspect-video max-md:aspect-[4/3] border hover:-translate-y-4 duration-300 bg-white/5 backdrop-blur-lg border-white/10 rounded-2xl overflow-hidden" key={idx}>
                                <div className="w-full aspect-[5/2] bg-background_primary">
                                    <img src={item.image} className='w-full h-full object-cover opacity-80' alt={item.title} draggable={false} />
                                </div>
                                <div className="h-full flex flex-col gap-2 p-8 max-md:p-6">
                                    <h2 className='text-2xl max-md:text-xl'>{item.title}</h2>
                                    <p className='text-text_disabled max-md:text-base'>{item.description}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
        </AnimatedContent>
    )
}
