import React from 'react'
import { AiSectionWelcome } from './AiSectionWelcome'
import { GetUpdate } from '../../components/organisms/GetUpdate'
import { AiSectionAbout } from './AiSectionAbout'

export const AiPage = () => {
  return (
    <div className='flex flex-col items-center justify-center text-lg'>
      <AiSectionWelcome />
      <AiSectionAbout />
      <GetUpdate />

    </div>
  )
}
