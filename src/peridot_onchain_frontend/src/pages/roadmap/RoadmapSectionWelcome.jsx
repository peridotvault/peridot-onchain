import React from 'react'
import Aurora from '../../components/atoms/Aurora'

export const RoadmapSectionWelcome = () => {
    return (
        <section className='w-full h-[50dvh] relative p-4 '>
            <div className="h-full w-full bg-background_secondary relative rounded-2xl overflow-hidden">
                <Aurora
                    colorStops={["#4D8A6A", "#90EE90", "#4D8A6A"]}
                    blend={0.5}
                    amplitude={0.8}
                    speed={0.5}
                />
            </div>
            <div className="absolute w-full h-full top-0 left-0 p-8 flex justify-center ">

                <div className="w-full max-w-[900px] h-full flex flex-col gap-4 justify-center items-center ">
                    <h1 className='text-7xl font-bold'>Roadmap</h1>
                    <p className='text-2xl text-center'>We have successfully developed the platform architecture and laid the groundwork for AI integration, setting the stage for a robust and innovative gaming experience.</p>
                </div>
            </div>
        </section>
    )
}
