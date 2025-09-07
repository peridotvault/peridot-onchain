import React from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faHandPointDown } from '@fortawesome/free-solid-svg-icons'
import { AiChat } from '../../components/molecules/AiChat';

export const AiSectionWelcome = () => {

    return (
        <section className="w-full h-screen p-4">
            <div className="bg-background_secondary w-full h-full rounded-2xl relative">
                {/* Chats  */}
                <AiChat />

                {/* additional Component  */}
                <div className="absolute z-0 bottom-8 left-0 flex flex-col items-center gap-2 w-full justify-center animate-bounce">
                    <span>Explore More</span>
                    <FontAwesomeIcon icon={faHandPointDown} />
                </div>
            </div>
        </section>
    )
}
