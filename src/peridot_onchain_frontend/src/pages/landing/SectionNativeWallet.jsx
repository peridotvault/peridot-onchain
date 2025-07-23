import React from 'react'
import { faWallet } from '@fortawesome/free-solid-svg-icons'
import { FeatureHeader } from '../../components/atoms/FeatureHeader'

export const SectionNativeWallet = () => {
    return (
        <section className='max-w-[1200px] px-8 py-24 w-full '>

            <div className="flex flex-col gap-12 p-16 border border-background_disabled rounded-2xl">
                <FeatureHeader icon={faWallet} title={"Native Wallet"} description={"Your secure and intuitive Web3 wallet, seamlessly integrated into the platform. No extensions, no fuss."} />

                {/* contents  */}
                <div className="grid grid-cols-2 max-md:grid-cols-1 gap-8 bh">
                    {...Array.from({ length: 2 }).map((_, idx) => (
                        <div className="aspect-[4/3] border bg-white/5 backdrop-blur-lg border-white/10 rounded-3xl p-10 flex flex-col gap-4 justify-end" key={idx}>
                            <h2 className='text-2xl'>Buy Games Directly</h2>
                            <p className='text-text_disabled'>Purchase your favorite Web2 and Web3 titles seamlessly through one unified platform (no third-party stores needed).</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    )
}
