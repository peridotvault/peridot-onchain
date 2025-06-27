import React, { useEffect, useState } from 'react'
import { faBarsProgress, faBook, faCheck, faFan, faStore, faVault, faWallet } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import ParticlesComponent from '../components/particles/particles'
import SpotlightCard from '../components/atoms/SpotlightCard'

export const LandingPage = () => {

    const roadmapLists = [
        {
            title: "Initial Setup",
            description: "We have successfully developed the platform architecture and laid the groundwork for AI integration, setting the stage for a robust and innovative gaming experience.",
            done: true,
        },
        {
            title: "Core Platform Development",
            description: "We are implementing advanced wallet security measures, establishing the initial game vault and library features, and integrating a personalized game recommendation system to enhance user experience and ensure safe transactions.",
            done: false,
        },
        {
            title: "Feature Enhancement",
            description: "We are introducing an AI chatbot for enhanced user support, launching initial game download features, and deploying the PER token, our native currency within the Peridot ecosystem, to facilitate seamless transactions and interactions.",
            done: null,
        },
        {
            title: "Testing and Deployment",
            description: "We will rigorously test the platform to identify and resolve any bugs and performance issues, followed by the deployment of the system and the preparation of comprehensive user documentation to ensure a smooth onboarding experience.",
            done: null,
        },

    ]
    const teamLists = [
        {
            image: "./assets/the-founder.png",
            name: "Ranaufal Muha",
            title: "Founder, CEO",
        },
        {
            image: "./assets/the-cofounder.jpeg",
            name: "Michael Eko Hartono Gunawan",
            title: "Co-Founder, CTO",
        }
    ]


    function RoadmapComponent(index, title, description, done) {
        return (
            <div className="flex">
                <div className="w-1/3 flex items-center">
                    <p className='w-2/3 text-end p-5 font-light text-base'>{"[ phase " + (index + 1) + " ]"}</p>
                    <hr className='w-1/3 border-background_disabled ' />
                </div>
                <div className="border border-background_disabled"></div>
                <div className="w-2/3 px-10 py-20 border-t border-b border-background_disabled flex gap-6">
                    <div className={`h-14 aspect-square rounded-full justify-center flex items-center ${done ? "bg-accent_primary/50" : "border border-background_disabled"} `}>
                        {done ?
                            <FontAwesomeIcon icon={faCheck} />
                            : done == null ?
                                <FontAwesomeIcon icon={faBarsProgress} />
                                :
                                <FontAwesomeIcon icon={faFan} className='animate-spin' />

                        }
                    </div>
                    <div className={`flex flex-col gap-3`}>
                        <p className='text-xl font-bold'>{title}</p>
                        <p className='text-base font-light'>{description}</p>
                    </div>
                </div>
            </div>
        );
    }

    const FeatureComponent = ({ aspect, item }) => {
        return (
            <SpotlightCard className={`custom-spotlight-card border backdrop-blur-lg border-white/10 rounded-2xl ${aspect}`} spotlightColor="rgba(0, 229, 255, 0.2)">
                {item}
            </SpotlightCard>
        )
    }

    return (
        <main className='flex flex-col items-center justify-center text-lg gap-28'>
            <ParticlesComponent />

            {/* section 1 */}
            <section className="relative w-full flex flex-col items-center justify-center overflow-hidden">
                <div className="h-[150px]"></div>
                <div className="container flex justify-center items-end px-8 h-[45dvh]">
                    <div className="w-[800px] text-center flex flex-col gap-6 ">
                        <div className="flex justify-center">
                            <div className="shadow-xl backdrop-blur-xl bg-black/15 shadow-accent_primary/30 py-2 px-4 rounded-lg font-medium ring-1 ring-accent_primary/30 text-base">
                                <span >Peridot is now in Alpha version</span>
                            </div>
                        </div>
                        < h1 className='text-7xl font-bold'>Gaming isn't just a hobby.</h1>
                        <p className='text-2xl'>Peridot is a smart desktop launcher for Web2 & Web3 games, giving players real ownership and developers an easier way to publish.</p>
                    </div>
                </div>

            </section>

            <section className='max-w-[1350px] w-full px-12 grid grid-cols-2 gap-9 duration-300'>
                <div className="w-full flex flex-col gap-8">
                    <FeatureComponent aspect={"aspect-[3/2]"}
                        item={
                            <div className="">
                                <div className="flex items-center gap-4">
                                    <FontAwesomeIcon icon={faWallet} />
                                    <h2 className='text-2xl font-bold'>Native Wallet</h2>
                                </div>
                            </div>
                        }
                    />
                    <FeatureComponent aspect={"aspect-[9/10]"}
                        item={
                            <div className="">
                                <div className="flex items-center gap-4">
                                    <FontAwesomeIcon icon={faVault} />
                                    <h2 className='text-2xl font-bold'>Game Vault</h2>
                                </div>
                            </div>
                        }
                    />
                    <div className={`border border-white/10 bg-accent_secondary backdrop-blur-lg rounded-2xl w-full flex-1`}></div>
                </div>
                <div className="w-full flex flex-col gap-8">
                    <FeatureComponent aspect={"aspect-[6/7]"}
                        item={
                            <div className="">

                                <div className="flex items-center gap-4">
                                    <img src="./assets/icons/ai.png" alt="" className='h-6' />
                                    <h2 className='text-2xl font-bold'>AI Powered</h2>
                                </div>
                            </div>
                        }
                    />
                    <FeatureComponent aspect={"aspect-square"}
                        item={
                            <div className="">

                                <div className="flex items-center gap-4">
                                    <FontAwesomeIcon icon={faStore} />
                                    <h2 className='text-2xl font-bold'>Item Marketplace</h2>
                                </div>
                            </div>
                        }
                    />

                </div>
            </section>

            {/* section 2 */}
            <section id='about' className='container flex flex-col justify-center px-8 py-32 gap-10 w-full overflow-hidden'>
                <div className="w-[35rem] flex flex-col items-start gap-5">
                    <p className='bg-gradient-to-tr from-accent_secondary via-accent_primary to-accent_primary bg-clip-text text-transparent'>Gaming isn't just a hobby</p>
                    <p className='text-4xl font-bold'>Elevate Your Lifestyle with the Vault of Games</p>
                    <p className='text-xl'>Blockchain Gaming Platform that allows Gamers to Buy, Download, and Play their favorite Games.</p>
                </div>
                <div className="w-[20rem] flex flex-col items-start justify-start gap-5">
                    <button className='shadow-arise-sm hover:shadow-flat-sm py-3 rounded-xl px-6 w-full flex gap-3 items-center bg-background_primary'>
                        <FontAwesomeIcon icon={faVault} />
                        <p className='text-start'>
                            Game Vault</p>
                    </button>
                    <button className='shadow-arise-sm hover:shadow-flat-sm py-3 rounded-xl px-6 w-full flex gap-3 items-center bg-background_primary'>
                        <FontAwesomeIcon icon={faWallet} />
                        <p className='text-start'>Native Wallet</p>
                    </button>
                    <button className='shadow-arise-sm hover:shadow-flat-sm py-3 rounded-xl px-6 w-full flex gap-3 items-center bg-background_primary'>
                        <FontAwesomeIcon icon={faStore} />
                        <p className='text-start'>Item Marketplace</p>
                    </button>
                </div>
            </section>

            {/* section 3 */}
            <section className='container flex flex-col justify-center px-8 gap-20 py-32'>
                <div className="flex flex-col items-center gap-5">
                    <div className="flex gap-2 items-center">
                        <img src="./assets/icons/ai.png" alt="" className='h-8' />
                        <p className='text-4xl font-bold'>AI-Powered</p>
                    </div>
                    <p className='text-xl max-w-[50rem] text-center'>Discover the future of gaming with Peridot's AI-Powered features, designed to elevate your gaming experience to new heights.</p>
                </div>
                <div className="flex flex-col gap-10">
                    <div className="flex items-center justify-start gap-5 relative overflow-hidden shadow-flat-sm rounded-xl  w-full bg-background_primary">
                        {/* left */}
                        <div className='flex flex-col items-start gap-3 py-32 px-10 z-20'>
                            <p className='text-start text-2xl font-bold'>AI Companion</p>
                            <p className='text-start max-w-[30rem] font-light'>
                                Never game alone again. Our AI Companion is your ultimate teammate, offering strategic insights, real-time support, and engaging interactions.
                            </p>
                            <button className='shadow-arise-sm py-3 px-6 rounded-xl mt-3 bg-background_primary'>Learn more</button>
                        </div>
                        {/* right */}
                        <div className="z-10 h-full">
                            <img src="./assets/al1.png" alt="" className='top-0 -right-10 absolute object-contain' />
                        </div>
                        {/* background  */}
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

                            {/* background  */}
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
                            {/* background  */}
                            <img src="./assets/bgl2.jpg" alt="" className='absolute opacity-30 w-full h-full top-0 left-0 object-cover' />
                            <div className="w-[1500px] h-[1000px] translate-y-1/2 -translate-x-1/3 size-18 rounded-full bg-gradient-radial from-accent_primary via-background_primary opacity-10 absolute bottom-0 "></div>
                        </div>
                    </div>
                </div>
            </section>

            {/* section 4 */}
            <section className='w-full py-16 flex items-start justify-center gap-16 shadow-sunken-sm relative bg-background_primary grayscale'>
                <img src="./assets/images/antigane.png" alt="" className='h-8' />
                <img src="https://internetcomputer.org/img/IC_logo_horizontal_white.svg" alt="" className='h-8' />
                <img src="https://indonesiaonchain.com/wp-content/uploads/2024/03/Disruptives-_-blck-letter-2-1024x181.png" alt="" className='h-8 invert' />
                {/* fade  */}
                <div className="">
                    <div className="bg-gradient-to-r from-background_primary w-52 h-full absolute top-0 left-0"></div>
                    <div className="bg-gradient-to-l from-background_primary w-52 h-full absolute top-0 right-0"></div>
                </div>
            </section>

            {/* section 5 */}
            <section id='roadmap' className='container flex flex-col justify-center px-8 gap-20 py-32'>
                <div className="flex flex-col items-center gap-5">
                    <p className='text-4xl font-light'>
                        <label className=' font-bold'>Roadmap </label>
                        <label >To Revolution</label>
                    </p>
                    <p className='text-xl max-w-[50rem] text-center'>Our roadmap outlines our commitment to innovation and community engagement as we transform the gaming landscape.</p>
                </div>
                {/* content  */}
                <div className="flex flex-col">
                    {roadmapLists.map((item, index) => (
                        RoadmapComponent(index, item.title, item.description, item.done)
                    ))}
                </div>
            </section>

            {/* section 6 Team */}
            <section id='team' className='container flex flex-col justify-center px-8 gap-20 py-32 '>
                <div className="flex flex-col items-center gap-5">
                    <p className='text-4xl font-light '>Meet Our Team</p>
                    <p className='text-xl w-[50rem] text-center'>Passionate Innovators Driving Peridot Forward</p>
                </div>
                {/* content  */}
                <div className="flex max-md:flex-col justify-center items-center gap-10">
                    {teamLists.map((item) => (
                        <div className="w-[400px] aspect-[4/7] max-md:w-full max-md:aspect-[3/4] rounded-xl relative overflow-hidden hover:shadow-flat-lg">
                            <img src={item.image} className='w-full h-full object-cover absolute top-0 left-0 -z-10' />
                            <div className="bg-gradient-to-t from-background_primary w-full h-full absolute top-0 left-0 -z-10"></div>
                            {/* data  */}
                            <div className="flex flex-col gap-3 w-full h-full justify-end items-start p-10">
                                <p className='text-3xl'>{item.name}</p>
                                <p className='text-xl'>{item.title}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </section>

            {/* Background ✅ */}
            <div className="absolute top-0 left-0 w-full h-4/5 max-h-[1000px] -z-20">
                <video
                    autoPlay
                    muted
                    loop
                    className=" w-full h-full object-cover opacity-80"
                >
                    <source src="https://res.cloudinary.com/dcf3oktvs/video/upload/v1743225301/hb1b0kqgmkjlpy9qglzy.mp4" />
                </video>

                <div className="w-full h-[200px] bg-gradient-to-b from-background_primary absolute opacity-80 top-0 z-10"></div>
                <div className="w-full h-[25%] bg-gradient-to-t from-background_primary absolute bottom-0 z-10"></div>
            </div>

        </main>
    )
}
