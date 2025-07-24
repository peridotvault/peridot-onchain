import React from 'react'
import { faGamepad } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'

export const SectionGameVault = () => {
    const list = [
        {
            title: "Buy Games Directly",
            description: "Purchase your favorite Web2 and Web3 titles seamlessly",
        },
        {
            title: "True Ownership",
            description: "Own your games as blockchain-backed assets forever",
        }, {

            title: "Web2 & Web3 in One Place",
            description: "Play traditional and blockchain games on one seamless platform",
        }
    ]
    return (
        <section className='max-w-[1200px] px-8 py-24 w-full flex flex-col gap-12'>
            <FeatureHeader icon={faGamepad} title={"GameVault"} description={"Experience a new era of gaming with GameVault where buying games is simple, fast, and transparent. Own your collection forever with blockchain-backed security."} />

            {/* contents  */}
            <div className="grid grid-cols-3 max-lg:grid-cols-2 max-md:grid-cols-1 gap-8">
                {list.map((item, idx) => (
                    <div className="aspect-square border rounded-2xl flex flex-col gap-8 py-8 bg-white/5 backdrop-blur-md border-white/10 hover:bg-accent_secondary duration-300" key={idx}>
                        <h2 className='text-xl px-8'>{item.title}</h2>
                        <hr className='border-t border-white/10 ' />
                        <p className='px-8 text-3xl'>{item.description}</p>
                    </div>
                ))}
            </div>
        </section>
    )
}
