import React from 'react'

export const LandingPage = () => {
    return (
        <main className='flex flex-col items-center justify-center gap-10 mt-32'>
            {/* section 1 */}
            <section className="container px-8 py-3">
                <div className="max-md:w-full">
                    <p className='text-fluid-h1 leading-fluid-h1 font-extrabold max-md:text-center bg-clip-text text-transparent bg-hero-pattern'>Elevate</p>
                    <p className='text-fluid-h2 leading-fluid-h2 font-semibold max-md:text-center'>Your Lifestyle with the </p>
                    <p className='text-fluid-h2 leading-fluid-h2 font-semibold max-md:text-center'> Vault of Games</p>
                </div>
            </section>

            {/* section 2 */}
            <section className='container px-8 py-3 my-32 flex items-start gap-8'>
                <div className="w-2/3 flex flex-col gap-8">
                    <p className='text-fluid-h2 leading-fluid-h2  text-start bg-clip-text font-bold text-transparent bg-gradient-to-bl from-purple-200 to-blue-200'>We are</p>
                    <p className='text-fluid-xl leading-fluid-xl font-semibold w-2/3'>blockchain gaming platform that allows gamers to buy, download, and play their favorite games</p>
                    <div className="flex">
                        <a href="" className='border text-fluid-sm py-2 px-5 rounded-xl'>Read More {'->'}</a>
                    </div>
                </div>
                <div className="w-1/3 leading-fluid-xl flex flex-col gap-8">
                    <div className="">
                        <p className='text-fluid-h2 leading-fluid-h2 font-semibold'>18+</p>
                        <p className='text-fluid-base font-light'>Game Vault</p>
                    </div>
                    <div className="">
                        <p className='text-fluid-h2 leading-fluid-h2 font-semibold'>2M+</p>
                        <p className='text-fluid-base font-light'>Active Gamers</p>
                    </div>
                    <div className="">
                        <p className='text-fluid-h2 leading-fluid-h2 font-semibold'>300+</p>
                        <p className='text-fluid-base font-light'>NFT Minted</p>
                    </div>
                </div>
            </section>

            {/* section 3 */}
            <section className=' py-3 font-medium flex flex-col gap-20 w-full'>
                <div className="w-full flex justify-center ">
                    <div className="container px-8">
                        <p className='text-fluid-h2 leading-fluid-h2 font-bold max-md:text-center text-end bg-clip-text text-transparent bg-gradient-to-br from-blue-200 to-green-200'>Featured Projects</p>
                    </div>
                </div>
                <div className="flex flex-col items-start text-fluid-lg">
                    {/* nomor 1  */}
                    <div className=" w-full flex justify-center ">
                        <div className="container flex gap-20 text-start items-center py-14 px-8">
                            <div className="w-1/2 flex flex-col gap-5">
                                <p className='text-fluid-h3 font-semibold leading-fluid-h3'>Game Vault</p>
                                <p className=''>Game Vault is a digital game distribution platform that facilitates game discovery, download management, and library organization, while offering developers publishing tools and players efficient game management and social features.</p>
                            </div>
                            <div className="w-1/2 aspect-[4/3] flex">
                                <div className="w-full h-full rounded-2xl overflow-hidden">
                                    <img src="./assets/GameVault.png" alt="" />
                                </div>
                            </div>
                        </div>
                    </div>
                    {/* nomor 2  */}
                    <div className=" w-full flex justify-center ">
                        <div className="container flex gap-20 text-start items-center  py-14 px-8">
                            <div className="w-1/2 flex flex-col gap-5">
                                <p className='text-fluid-h3 font-semibold leading-fluid-h3'>Native Wallet</p>
                                <p className=''>The Native Peridot Wallet is a self-custody wallet offering user control over private keys and advanced post-quantum security, supporting multiple cryptocurrencies and NFTs, with seamless integration for game purchases and trading.</p>
                            </div>
                            <div className="w-1/2 aspect-[4/3] flex">
                                <div className="w-full h-full rounded-2xl overflow-hidden">
                                    <img src="./assets/NativeWallet.png" alt="" />
                                </div>
                            </div>
                        </div>
                    </div>
                    {/* nomor 3  */}
                    <div className=" w-full flex justify-center ">
                        <div className="container flex gap-20 text-start items-center py-14 px-8">
                            <div className="w-1/2 flex flex-col gap-5">
                                <p className='text-fluid-h3 font-semibold leading-fluid-h3'>Item Marketplace</p>
                                <p className=''>The Item Marketplace features a real-time trading system with auction and fixed price listings, NFT integration for minting and collection management, and advanced item management tools, including search filters and price tracking, along with trading tools for market analytics and alerts.</p>
                            </div>
                            <div className="w-1/2 aspect-[4/3] flex">
                                <div className="w-full h-full rounded-2xl overflow-hidden bg-black">
                                    <img src="https://internetcomputer.org/img/home/chainfusion.webp" className='w-full h-full' alt="" />
                                </div>
                            </div>
                        </div>
                    </div>
                    {/* nomor 4  */}
                    <div className=" w-full flex justify-center ">
                        <div className="container flex gap-20 text-start  py-14 px-8 items-center">
                            <div className="w-1/2 flex flex-col gap-5">
                                <p className='text-fluid-h3 font-semibold leading-fluid-h3'>AI-Powered</p>
                                <p className=''>The AI-Powered system offers a personalized recommendation engine that enhances user engagement through tailored suggestions and a gaming pal that learns gameplay patterns, providing real-time assistance and personalized feedback to improve player skills and create an immersive experience.</p>
                            </div>
                            <div className="w-1/2 aspect-[4/3] flex">
                                <div className="w-full h-full rounded-2xl overflow-hidden">
                                    <img src="https://internetcomputer.org/img/home/ai.webp" alt="" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <div className="m-32"></div>

        </main>
    )
}
