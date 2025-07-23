import React from 'react'
import { faGamepad } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'

export const SectionGameVault = () => {
    return (
        <section className='max-w-[1200px] px-8 py-24 w-full flex flex-col gap-12'>
            <FeatureHeader icon={faGamepad} title={"GameVault"} description={"Peridot brings all your games together. Purchase and store both Web2 and Web3 games in one place enhanced by AI-Powered recommendations just for you"} />

            {/* contents  */}
            <div className="grid grid-cols-3 max-lg:grid-cols-2 max-md:grid-cols-1 gap-8">
                {...Array.from({ length: 3 }).map((_, idx) => (
                    <div className="aspect-square border rounded-2xl flex flex-col gap-8 py-8 bg-white/5 backdrop-blur-md border-white/10 hover:bg-accent_secondary duration-300" key={idx}>
                        <h2 className='text-xl px-8'>Buy Games Directly</h2>
                        <hr className='border-t border-white/10 ' />
                        <p className='px-8 text-3xl'>Purchase your favorite Web2 and Web3 titles seamlessly</p>
                    </div>
                ))}
            </div>
        </section>
    )
}
