import React from 'react'
import { faWallet } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'

export const SectionNativeWallet = () => {
    const list = [
        {
            title: "Built for Gamers",
            description: "A wallet that works like magic—effortless, integrated, and ready when you are.",
            image: "https://plus.unsplash.com/premium_vector-1727089084561-deb0f1033e93?q=80&w=1332&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        },
        {
            title: "Secure & Self-Custodial",
            description: "Your assets are yours—no banks, no middlemen, just pure control.",
            image: "https://plus.unsplash.com/premium_vector-1711987827897-00999d8387af?q=80&w=1242&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        },
    ]
    return (
        <section className='max-w-[1200px] px-8 py-24 w-full '>

            <div className="flex flex-col gap-12 p-16 max-md:p-10 border border-background_disabled rounded-2xl duration-300">
                <FeatureHeader icon={faWallet} title={"Native Wallet"} description={"Meet the wallet that feels invisible—always there, always secure. Complete control of your digital assets, without the complexity."} />

                {/* contents  */}
                <div className="grid grid-cols-2 max-lg:grid-cols-1 gap-8 bh">
                    {list.map((item, idx) => (
                        <div className="aspect-[4/3] border hover:-translate-y-4 duration-300 bg-white/5 backdrop-blur-lg border-white/10 rounded-3xl overflow-hidden" key={idx}>
                            <div className="bg-red-300 w-full aspect-[5/2]">
                                <img src={item.image} className='w-full h-full object-cover ' alt="" />
                            </div>
                            <div className="h-full flex flex-col gap-2 p-8">
                                <h2 className='text-2xl'>{item.title}</h2>
                                <p className='text-text_disabled'>{item.description}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}
