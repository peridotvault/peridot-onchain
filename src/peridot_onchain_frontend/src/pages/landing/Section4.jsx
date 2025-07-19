import React from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faGamepad } from '@fortawesome/free-solid-svg-icons'

export const Section4 = () => {
    return (
        <section className='max-w-[1400px] p-8 w-full flex flex-col'>
            <div className="flex w-full items-center">
                {/* TItle  */}
                <div className="flex items-center gap-6 w-2/5">
                    <FontAwesomeIcon icon={faGamepad} className='text-accent_primary text-5xl' />
                    <div >
                        <label className='uppercase text-sm text-accent_primary'>feature</label>
                        <h2 className='text-4xl font-bold'>GameVault</h2>
                    </div>
                </div>

                {/* description */}
                <p className='w-3/5'>Peridot brings all your games together. Purchase and store both Web2 and Web3 games in one place enhanced by AI-Powered recommendations just for you</p>
            </div>
        </section>
    )
}
