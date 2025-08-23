import React from 'react'
import Threads from '../../components/atoms/Threads'
import FaultyTerminal from '../../components/atoms/FaultyTerminal'

export const AiSectionWelcome = () => {
    return (
        <section className="w-full h-[50dvh] p-4">
            <div className="bg-background_secondary w-full h-full rounded-2xl overflow-hidden relative">
                <div className="absolute h-full z-10 flex items-center justify-center w-full pointer-events-none p-8 text-center">
                    <h1 className='text-7xl font-bold max-md:text-3xl'>Smarter Play, Powered by AI</h1>
                </div>
                {/* <Threads
                    amplitude={1}
                    distance={0}
                    enableMouseInteraction={true}
                /> */}
                <FaultyTerminal
                    scale={1.5}
                    gridMul={[2, 1]}
                    digitSize={1.2}
                    timeScale={1}
                    pause={false}
                    scanlineIntensity={1}
                    glitchAmount={1}
                    flickerAmount={1}
                    noiseAmp={1}
                    chromaticAberration={0}
                    dither={0}
                    curvature={0}
                    tint="#4D8A6A"
                    className={"opacity-30"}
                    mouseReact={true}
                    mouseStrength={0.5}
                    pageLoadAnimation={false}
                    brightness={1}
                />
            </div>
        </section>

    )
}
