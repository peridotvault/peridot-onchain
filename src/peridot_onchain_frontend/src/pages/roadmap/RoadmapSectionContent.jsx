import React from 'react'
import SpotlightCard from '../../components/atoms/SpotlightCard'

export const RoadmapSectionContent = () => {
    return (
        <div className='w-full flex justify-center px-8 py-40 gap-10'>
            <div className=" w-full flex flex-col gap-40">
                {Array.from({ length: 5 }).map((_, idx) => (
                    <Content key={idx} />
                ))}
            </div>
        </div>
    )
}

const Content = () => {
    return (
        <section className='w-full flex flex-col gap-14 items-center '>
            {/* Judul & deskripsi */}
            <div className="max-w-[1200px] w-full">
                <div className="flex flex-col gap-8 px-8">
                    <h2 className='text-4xl font-bold'>Desktop Application</h2>
                    <p className='w-2/3 max-w-[800px] text-xl'>
                        We have successfully developed the platform architecture and laid the groundwork for AI integration, setting the stage for a robust and innovative gaming experience.
                    </p>
                </div>
            </div>

            {/* Scrollable cards */}
            <div className="w-full overflow-x-auto scrollbar-hide">
                <div className="max-w-[1200px] mx-auto px-8">
                    <div className="flex gap-8 w-max">
                        {Array.from({ length: 5 }).map((_, idx) => (
                            <SpotlightCard
                                key={idx}
                                className="flex-shrink-0 custom-spotlight-card p-8 rounded-xl aspect-video w-[450px] flex flex-col justify-between"
                            >
                                <div className="flex justify-between">
                                    <div className="flex flex-col gap-2">
                                        <h3 className='text-2xl font-bold'>Initialization</h3>
                                        <p>
                                            <span className='text-text_disabled'>Completed</span> August 3, 2024
                                        </p>
                                    </div>
                                    <div className="h-full rounded-full aspect-square border border-success bg-accent_secondary"></div>
                                </div>
                                <div className="flex justify-between items-end">
                                    <p className='text-lg'>
                                        Lorem ipsum dolor sit amet consectetur adipisicing elit. Vitae, maiores.
                                    </p>
                                    <div className="flex flex-col items-end">
                                        <span className='text-8xl'>3</span>
                                        <span>Features</span>
                                    </div>
                                </div>
                            </SpotlightCard>
                        ))}
                    </div>
                </div>
            </div>
        </section>
    )
}
