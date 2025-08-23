import React from 'react'
import { ContainerGlass } from '../../components/molecules/ContainerGlass'

export const AiSectionNightPlanner = () => {
    const list = [
        {
            title: "Intelligent Scheduling",
            description: "Automatically plans sessions by matching players’ schedules for the perfect game time",
        },
        {
            title: "Game Suggestions",
            description: "Recommends games everyone will enjoy, based on shared interests and past activity",
        }, {

            title: "Smart Reminders",
            description: "Sends timely notifications to keep everyone in sync before and after game night.",
        }
    ]
    return (
        <section className='max-w-[1200px] px-8 py-24 max-md:py-10 w-full flex flex-col gap-12 max-md:gap-6'>
            <div className="grid grid-cols-2 max-md:grid-cols-1 gap-4">
                <h2 className='bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent text-5xl max-md:text-3xl font-bold'>Game Night Planner</h2>
                <p className='max-md:text-base'>Planning a game night has never been easier. Let our AI handle time zones, player availability, game compatibility, and even suggest fun formats for your next session.</p>
            </div>
            {/* contents  */}
            <div className="grid grid-cols-3 max-lg:grid-cols-2 max-md:grid-cols-1 gap-8 max-md:gap-6">
                {list.map((item, idx) => (
                    <ContainerGlass key={idx} title={item.title} description={item.description} />
                ))}
            </div>
        </section>
    )
}
