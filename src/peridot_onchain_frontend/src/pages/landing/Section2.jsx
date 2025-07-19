import React from 'react'

export const Section2 = () => {
    return (
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
    )
}
