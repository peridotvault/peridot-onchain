import React from 'react'
import { faWallet } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'

export const SectionNativeWallet = () => {
    const list = [
        {
            title: "Built for Gamers",
            description: "A wallet that works like magic—effortless, integrated, and ready when you are.",
        },
        {
            title: "Secure & Self-Custodial",
            description: "Your assets are yours—no banks, no middlemen, just pure control.",
        },
    ]
    return (
        <section className='max-w-[1200px] px-8 py-24 w-full '>

            <div className="flex flex-col gap-12 p-16 max-md:p-10 border border-background_disabled rounded-2xl duration-300">
                <FeatureHeader icon={faWallet} title={"Native Wallet"} description={"Meet the wallet that feels invisible—always there, always secure. Complete control of your digital assets, without the complexity."} />

                {/* contents  */}
                <div className="grid grid-cols-2 max-lg:grid-cols-1 gap-8 bh">
                    {list.map((item, idx) => (
                        <div className="aspect-[4/3] border hover:-translate-y-4 duration-300 bg-white/5 backdrop-blur-lg border-white/10 rounded-3xl p-10 flex flex-col gap-4 justify-end" key={idx}>
                            <h2 className='text-2xl'>{item.title}</h2>
                            <p className='text-text_disabled'>{item.description}</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}
