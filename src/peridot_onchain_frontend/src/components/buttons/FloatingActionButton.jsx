import React from 'react'
import StarBorder from '../atoms/StarBorder'

export const FloatingActionButton = () => {
  return (
    <div className="fixed bottom-20 right-20">
        <StarBorder speed='2s' className='py-3 px-6 bg-accent_secondary to-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group'>
            <span className="font-bold">
                Chat with AI
            </span>
        </StarBorder>
    </div>
  )
}