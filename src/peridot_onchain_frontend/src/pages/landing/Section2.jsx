import React from 'react'
import GlassComponent from '../../components/atoms/GlassComponent'

export const Section2 = () => {
    return (
        <section className='w-full flex justify-center py-24'>
            <GlassComponent
                className="w-full max-w-[1200px] py-16 mx-8 flex gap-16 items-center justify-center rounded-2xl"
            >
                <div className="flex flex-col">
                    <span className='text-base'>Our Platform</span>
                    <span className='uppercase text-4xl font-bold text-accent_primary'>Powered By</span>
                </div>
                <img src="./assets/images/icp.svg" alt="" className='h-12 grayscale' />
                <img src="./assets/images/icp-idn.png" alt="" className='h-12 invert grayscale' />
                {/* fade  */}
                {/* <div className="">
                    <div className="bg-gradient-to-r from-background_primary w-52 h-full absolute top-0 left-0"></div>
                    <div className="bg-gradient-to-l from-background_primary w-52 h-full absolute top-0 right-0"></div>
                    </div> */}
            </GlassComponent>
        </section>
    )
}
