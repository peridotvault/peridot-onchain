import React from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

export const GetUpdate = () => {
    return (
        <section className='w-full px-8 pb-4 pt-24 max-md:pt-10 flex justify-center '>
            <div className="w-full max-w-[1200px] rounded-3xl max-md:rounded-2xl bg-gradient-to-br from-accent_secondary to-accent_primary/5 px-24 max-md:px-8">
                <div className="flex h-full flex-col justify-center max-w-[700px] py-24 max-md:py-12 max-lg:w-full max-lg:justify-start gap-8 max-md:gap-6">
                    <h2 className='text-4xl max-md:text-2xl'>Get Peridot updates, insights, and exclusive announcements delivered directly to you.</h2>
                    <div className="flex gap-4 w-full max-w-[400px] ">
                        <input type="email" name="" id="" className='py-4 px-8 max-md:px-6 max-md:text-base rounded-xl w-full bg-white/20 backdrop-blur-lg border-white/10' placeholder='Email Address' required />
                        <button className='aspect-square bg-accent_secondary h-full rounded-xl text-white'>
                            <FontAwesomeIcon icon={faChevronRight} />
                        </button>
                    </div>
                </div>

            </div>
        </section>
    )
}
