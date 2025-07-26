import React from 'react'
import CardSwap, { Card } from '../atoms/CardSwap'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

export const GetUpdate = () => {
    return (
        <section className='w-full max-w-[1200px] px-8 pt-24 pb-48 flex justify-center '>
            <div className="w-full overflow-hidden relative rounded-3xl bg-gradient-to-br from-accent_secondary to-accent_primary/5">

                <div className="absolute h-full flex flex-col justify-center w-1/2 p-12 max-lg:w-full max-lg:justify-start gap-8 z-20">
                    <h2 className='text-4xl'>Get Peridot updates, insights, and exclusive announcements.</h2>
                    <div className="flex gap-4 w-full max-w-[400px]">
                        <input type="email" name="" id="" className='py-4 px-8 rounded-xl w-full bg-white/20 backdrop-blur-lg border-white/10' placeholder='Email Address' required />
                        <button className='aspect-square bg-accent_secondary h-full rounded-xl text-white'>
                            <FontAwesomeIcon icon={faChevronRight} />
                        </button>
                    </div>
                </div>
                <div style={{ height: '600px', position: 'relative', zIndex: "10" }} >
                    <CardSwap
                        cardDistance={60}
                        verticalDistance={70}
                        delay={5000}
                        pauseOnHover={false}
                    >
                        <Card>
                            <h3 >Update</h3>
                            {/* <img src="./assets/pages/GameVault.png" alt="" /> */}
                        </Card>
                        <Card>
                            <h3 >Insights</h3>
                            {/* <img src="./assets/pages/NativeWallet.png" alt="" /> */}
                        </Card>
                        <Card>
                            <h3 >Announcements</h3>
                            {/* <img src="./assets/pages/Library.png" alt="" /> */}
                        </Card>
                    </CardSwap>
                </div>
            </div>
        </section>
    )
}
