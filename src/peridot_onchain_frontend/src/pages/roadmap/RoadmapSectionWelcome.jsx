import React from 'react'
import FaultyTerminal from '../../components/atoms/FaultyTerminal'

export const RoadmapSectionWelcome = () => {
    return (
        <section className='w-full h-[50dvh] relative p-4 '>
            <div className="h-full w-full bg-background_secondary relative rounded-2xl overflow-hidden">
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
            <div className="absolute w-full h-full top-0 left-0 p-8 flex justify-center ">

                <div className="w-full max-w-[1200px] h-full flex flex-col gap-4 justify-center items-start text-start">
                    <h1 className='text-7xl font-bold'>Roadmap</h1>
                    <p className='text-2xl w-2/3'>We have successfully developed the platform architecture and laid the groundwork for AI integration, setting the stage for a robust and innovative gaming experience.</p>
                </div>
            </div>
        </section>
    )
}
