import React from 'react'
import GradientBlinds from '../../components/atoms/GradientBlinds'
import { Link } from 'react-router-dom'
import StarBorder from '../../components/atoms/StarBorder'
import GlassComponent from '../../components/atoms/GlassComponent'

export const AiSectionWelcome = () => {
    return (
        <section className="w-full h-[80dvh] p-4">
            <div className="bg-background_secondary w-full h-full rounded-2xl overflow-hidden relative">
                <div className="absolute h-full z-10 flex flex-col gap-10 items-center justify-center w-full pointer-events-none p-8 text-center">
                    <h1 className='text-6xl font-bold max-md:text-3xl'>Smarter Play, Powered by AI</h1>
                    <div className="flex gap-6">
                        <Link to={"/peri"} className='pointer-events-auto' >
                            <StarBorder speed="2s" className='py-3 px-6 bg-accent_secondary to-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group'>
                                <p >Try PERI</p>
                            </StarBorder>
                        </Link>
                        <Link to={"/ai/#gaming_with_ai"} className='pointer-events-auto' >
                            <GlassComponent className='flex justify-center items-center py-3 px-6 rounded-lg duration-300 hover:bg-background_secondary hover:text-white overflow-hidden text-text_disabled'>
                                <p >Learn More</p>
                            </GlassComponent>
                        </Link>
                    </div>
                </div>


                <GradientBlinds
                    gradientColors={['#90EE90', '#4D8A6A']}
                    angle={20}
                    noise={0.5}
                    blindCount={20}
                    blindMinWidth={50}
                    spotlightRadius={0.5}
                    spotlightSoftness={1}
                    spotlightOpacity={1}
                    mouseDampening={0.15}
                    distortAmount={0}
                    shineDirection="left"
                    mixBlendMode="lighten"
                />
            </div>
        </section>

    )
}