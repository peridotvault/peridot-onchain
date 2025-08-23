import React from 'react'
import GlassComponent from '../../components/atoms/GlassComponent'

export const Section2 = () => {
    return (
        <section className='w-full flex justify-center py-24 max-md:py-8'>
            <GlassComponent
                className="w-full max-w-[1200px] py-16 max-md:py-10 max-md:gap-8 mx-8 max-md:mx-4 flex gap-16 items-center justify-center rounded-2xl"
            >
                <div className="flex flex-col max-md:hidden duration-300">
                    <span className='text-base'>Our Platform</span>
                    <span className='uppercase text-4xl font-bold text-accent_primary'>Powered By</span>
                </div>
                <img src="./assets/images/icp.svg" alt="" className='h-12 max-md:h-8 grayscale duration-300' draggable={false} />
                <img src="./assets/images/icp-idn.png" alt="" className='h-12 max-md:h-8 invert grayscale duration-300' draggable={false} />
            </GlassComponent>
        </section>
    )
}
