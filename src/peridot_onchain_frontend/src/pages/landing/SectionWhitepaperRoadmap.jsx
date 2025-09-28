import React from 'react'
import { Link } from 'react-router-dom'
import AnimatedContent from '../../components/animations/AnimatedContent'

export const SectionWhitepaperRoadmap = () => {
    const ComponentSection = ({ id, title, description, hookText, href, imgUrl }) => {
        return (
            <section id={id} className='w-full bg-background_primary border border-background_disabled aspect-[3/4] max-md:aspect-[4/3] duration-300 rounded-2xl overflow-hidden relative'>
                {/* background  */}
                <div className="absolute inset-0 z-0 top-0 left-0">
                    <img src={imgUrl} draggable={false} className='w-full h-full object-cover translate-y-[30%] object-top' loading='lazy' decoding='async' alt={title} />
                    <div className="bg-gradient-to-b from-background_primary via-background_primary absolute top-0 w-full h-2/3"></div>
                </div>

                {/* content  */}
                <div className="relative p-24 max-md:p-8 flex flex-col gap-8 max-md:gap-4 text-xl z-10">
                    <h2 className='text-4xl font-bold max-md:text-3xl'>{title}</h2>
                    <p className='max-md:text-base'>{description}</p>
                    <div className="py-4 max-md:py-2">
                        <Link to={href} className='border py-4 max-md:py-2 px-6 max-md:px-4 max-md:text-base max-md:rounded-lg rounded-xl border-white/20 duration-300 hover:-translate-y-1 bg-white/10 hover:bg-accent_secondary'>{hookText}</Link>
                    </div>
                </div>
            </section>
        )
    }
    return (


        <AnimatedContent>
            <div className='w-full flex justify-center py-24 max-md:py-10'>
                <div className="max-w-[1200px] w-full grid grid-cols-2 max-md:grid-cols-1 gap-8 px-8 max-md:px-4">
                    <ComponentSection id={"whitepaper"} title="Whitepaper" description={"Explore the vision, technology, and economics behind PeridotVault. Our whitepaper details how we’re building the future of gaming—secure, decentralized, and player-first."} hookText="Read Now" href={"#"} imgUrl={"./assets/views/landing/whitepaper.webp"} />
                    <ComponentSection id={"roadmap"} title="Roadmap" description="From concept to reality, our roadmap reflects our commitment to innovation and transparency. Track every stage as PeridotVault evolves." hookText="Get into it" href={"/roadmap"} imgUrl={"./assets/views/landing/roadmap.gif"} />
                </div>
            </div>
        </AnimatedContent>
    )
}
