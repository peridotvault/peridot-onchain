import React from 'react'
import { Link } from 'react-router-dom'

export const SectionWhitepaperRoadmap = () => {
    const ComponentSection = ({ id, title, description, hookText, href }) => {
        return (
            <section id={id} className='w-full bg-background_primary border border-background_disabled aspect-[3/4] rounded-2xl overflow-hidden'>
                <div className="p-24 flex flex-col gap-8 text-xl">
                    <h2 className='text-4xl font-bold'>{title}</h2>
                    <p>{description}</p>
                    <div className="py-4">
                        <Link to={href} className='border py-4 px-6 rounded-xl border-text_disabled'>{hookText}</Link>
                    </div>
                </div>
            </section>
        )
    }
    return (


        <div className='w-full flex justify-center py-24'>
            <div className="max-w-[1200px] w-full grid grid-cols-2 max-md:grid-cols-1 gap-8 px-8">
                <ComponentSection id={"whitepaper"} title="Whitepaper" description={"Explore the vision, technology, and economics behind PeridotVault. Our whitepaper details how we’re building the future of gaming—secure, decentralized, and player-first."} hookText="Read Now" href={"#"} />
                <ComponentSection id={"roadmap"} title="Roadmap" description="From concept to reality, our roadmap reflects our commitment to innovation and transparency. Track every stage as PeridotVault evolves." hookText="Get into it" href={"#"} />
            </div>
        </div>
    )
}
