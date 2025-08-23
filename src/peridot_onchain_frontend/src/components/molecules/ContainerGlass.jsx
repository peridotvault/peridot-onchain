import React from 'react'

export const ContainerGlass = ({ title, description }) => {
    return (
        <div className="aspect-square max-md:aspect-video border rounded-2xl flex flex-col gap-8 py-8 bg-white/5 backdrop-blur-md border-white/10 hover:bg-accent_secondary duration-300">
            <h3 className='text-xl px-8'>{title}</h3>
            <hr className='border-t border-white/10 ' />
            <p className='px-8 text-3xl'>{description}</p>
        </div>
    )
}
