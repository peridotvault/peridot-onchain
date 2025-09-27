import React from 'react'
import AnimatedContent from '../../components/animations/AnimatedContent'

export const AiSectionPersonalized = () => {
    const list = [
        {
            title: "Custom-tailored Game Suggestions",
            description: "Discover games picked specifically for you, based on your interests and play history",
        },
        {
            title: "Continuous Learning Interactions",
            description: "The system improves over time by understanding how you browse, play, and engage",
        },
    ]
    return (
        <AnimatedContent>
            <section className='max-w-[1200px] px-8 py-24 w-full flex flex-col items-center gap-8 max-md:gap-6 max-md:py-10'>
                <h2 className='text-center text-5xl bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent font-bold max-md:text-3xl max-md:text-start'>Personalized Recommendations</h2>
                <p className='text-center max-w-5xl max-md:text-start max-md:text-base'>Peridot's AI analyzes your play history, genre preferences, behavior patterns, and community trends to recommend games you’re most likely to enjoy. It’s more than a store algorithm — it’s a personal curator for your gaming taste.</p>

                <div className="w-full grid grid-cols-5 max-lg:grid-cols-2 gap-8">
                    <div className="col-span-3 max-lg:col-span-2 relative max-lg:aspect-video overflow-hidden rounded-2xl">
                        <img src="./assets/views/ai/gaming.gif" alt="" className='w-full h-full absolute top-0 left-0 object-cover' draggable={false} />
                        <h3 className='absolute bottom-0 left-0 p-12 max-md:p-8 text-3xl max-md:text-2xl'>Enjoy personalized suggestions across both traditional and blockchain-based games</h3>
                    </div>
                    {/* content feature  */}
                    <div className="col-span-2 grid max-lg:grid-cols-2 max-md:grid-cols-1 gap-8">
                        {list.map((item, idx) => (
                            <div key={idx} className="aspect-[4/3] max-md:aspect-video border rounded-2xl flex flex-col gap-8 py-8 bg-white/5 backdrop-blur-md border-white/10 hover:bg-accent_secondary duration-300 max-md:py-6 max-md:gap-6">
                                <h3 className='text-xl px-8 max-md:text-lg'>{item.title}</h3>
                                <hr className='border-t border-white/10 ' />
                                <p className='px-8 text-3xl max-md:text-2xl'>{item.description}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
        </AnimatedContent>
    )
}
