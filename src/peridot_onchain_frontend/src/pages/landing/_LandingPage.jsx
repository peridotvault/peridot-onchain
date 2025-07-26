import React from 'react'
import { Section1 } from './Section1';
import { Section2 } from './Section2';
import { Section3 } from './Section3';
import { SectionGameVault } from './SectionGameVault';
import { GetUpdate } from '../../components/organisms/GetUpdate';
import { SectionTeam } from './SectionTeam';
import { SectionWhitepaperRoadmap } from './SectionWhitepaperRoadmap';
import { SectionNativeWallet } from './SectionNativeWallet';
import ParticlesComponent from '../../components/particles/particles';

export const LandingPage = () => {

    return (
        <div className='flex flex-col items-center justify-center text-lg'>
            <ParticlesComponent />

            {/* section 1 */}
            <Section1 />
            <Section2 />
            <Section3 />
            <SectionGameVault />
            <SectionNativeWallet />

            {/* section 2 */}

            {/* section 3 */}
            {/* <section className='max-w-[1400px] w-full flex flex-col justify-center px-8 gap-20 py-24'>
                <div className="flex flex-col items-center gap-5">
                    <div className="flex gap-2 items-center">
                        <img src="./assets/icons/ai.png" alt="" className='h-8' />
                        <p className='text-4xl font-bold'>AI-Powered</p>
                    </div>
                    <p className='text-xl max-w-[50rem] text-center'>Discover the future of gaming with Peridot's AI-Powered features, designed to elevate your gaming experience to new heights.</p>
                </div>
                <div className="flex flex-col gap-10">
                    <div className="flex items-center justify-start gap-5 relative overflow-hidden shadow-flat-sm rounded-xl  w-full bg-background_primary">
                        //  left 
                        <div className='flex flex-col items-start gap-3 py-32 px-10 z-20'>
                            <p className='text-start text-2xl font-bold'>AI Companion</p>
                            <p className='text-start max-w-[30rem] font-light'>
                                Never game alone again. Our AI Companion is your ultimate teammate, offering strategic insights, real-time support, and engaging interactions.
                            </p>
                            <button className='shadow-arise-sm py-3 px-6 rounded-xl mt-3 bg-background_primary'>Learn more</button>
                        </div>
                        // right 
                        <div className="z-10 h-full">
                            <img src="./assets/al1.png" alt="" className='top-0 -right-10 absolute object-contain' />
                        </div>
                        // background  
                        <img src="./assets/bgl2.jpg" alt="" className='absolute opacity-30 w-full h-full top-0 left-0 object-cover' />
                        <div className="w-[1500px] h-[1000px] translate-y-1/2 -translate-x-1/3 size-18 rounded-full bg-gradient-radial from-accent_primary via-background_primary opacity-10 absolute bottom-0 "></div>
                    </div>
                    <div className="flex max-md:flex-col gap-10">
                        <div className='shadow-flat-sm hover:shadow-flat-sm rounded-xl p-10 flex flex-col justify-between items-start gap-3 max-md:w-full w-1/2 bg-background_primary relative overflow-hidden'>
                            <div className="z-10 flex flex-col gap-2">
                                <p className='text-start text-2xl font-bold'>Personalize Recommendation</p>
                                <p className='text-start font-light'>
                                    Play smarter, not harder. With our Personalized Recommendations, discover games that match your unique preferences and play style.
                                </p>
                            </div>
                            <div className="flex justify-center w-full mt-3 z-10">
                                <img src="./assets/al2.png" alt="" className='w-[20rem] object-contain' />
                            </div>

                            // background 
                            <img src="./assets/bgl2.jpg" alt="" className='absolute opacity-30 w-full h-full top-0 left-0 object-cover' />
                            <div className="w-[1500px] h-[1000px] translate-y-1/2 -translate-x-1/3 size-18 rounded-full bg-gradient-radial from-accent_primary via-background_primary opacity-10 absolute bottom-0 "></div>
                        </div>
                        <div className='shadow-flat-sm hover:shadow-flat-sm rounded-xl p-10 flex flex-col justify-between items-start gap-3 max-md:w-full w-1/2 relative overflow-hidden'>
                            <div className="z-10 flex flex-col gap-2">
                                <p className='text-start text-2xl font-bold '>Game Night Planner</p>
                                <p className='text-start font-light '>
                                    Say goodbye to the hassle of organizing game nights and let our intelligent planner do the work for you!
                                </p>
                            </div>
                            <div className="flex justify-center w-full z-10">
                                <img src="./assets/al3.png" alt="" className='w-[20rem] object-contain' />
                            </div>
                            //background 
                            <img src="./assets/bgl2.jpg" alt="" className='absolute opacity-30 w-full h-full top-0 left-0 object-cover' />
                            <div className="w-[1500px] h-[1000px] translate-y-1/2 -translate-x-1/3 size-18 rounded-full bg-gradient-radial from-accent_primary via-background_primary opacity-10 absolute bottom-0 "></div>
                        </div>
                    </div>
                </div>
            </section> */}


            <SectionWhitepaperRoadmap />
            <SectionTeam />
            <GetUpdate />

            {/* <section>
                <ScrollVelocity
                    texts={['PeridotVault * Gaming Platform *', 'Secure * Fun * Decentralize *']}
                    velocity={50}
                    className="custom-scroll-text"
                />
            </section> */}

        </div>
    )
}
