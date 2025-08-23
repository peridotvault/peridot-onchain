import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import React from 'react'

export const FeatureHeader = ({ icon, title, description }) => {
    return (
        <div className="flex w-full items-start gap-4 max-md:flex-col">
            {/* TItle  */}
            <div className="flex items-center gap-6 max-md:gap-4 w-2/5 max-md:w-full">
                <FontAwesomeIcon icon={icon} className='text-accent_primary text-5xl' />
                <div >
                    <label className='uppercase text-sm max-md:text-xs text-accent_primary'>feature</label>
                    <h2 className='text-4xl font-bold max-md:text-3xl'>{title}</h2>
                </div>
            </div>

            {/* description */}
            <p className='w-3/5 max-md:w-full max-md:text-base'>{description}</p>
        </div>
    )
}
