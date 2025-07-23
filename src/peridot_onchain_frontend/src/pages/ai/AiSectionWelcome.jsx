import React from 'react'
import Threads from '../../components/atoms/Threads'

export const AiSectionWelcome = () => {
    return (
        <section className="w-full h-[50dvh] p-4">
            <div className="bg-background_secondary w-full h-full rounded-2xl overflow-hidden relative">
                <div className="absolute h-full z-10 flex items-center justify-center w-full pointer-events-none p-8 text-center">
                    <h1 className='text-7xl font-bold'>Smarter Play, Powered by AI</h1>
                </div>
                <Threads
                    amplitude={1}
                    distance={0}
                    enableMouseInteraction={true}
                />
            </div>
        </section>

    )
}
