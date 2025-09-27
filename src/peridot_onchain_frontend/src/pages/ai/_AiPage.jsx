import React, { useEffect } from 'react'
import { AiSectionWelcome } from './AiSectionWelcome'
import { GetUpdate } from '../../components/organisms/GetUpdate'
import { AiSectionAbout } from './AiSectionAbout'
import { AiSectionCompanion } from './AiSectionCompanion'
import { AiSectionPersonalized } from './AiSectionPersonalized'
import { AiSectionNightPlanner } from './AiSectionNightPlanner'

export const AiPage = () => {

  useEffect(() => {
    window.scrollTo(0, 0);

  }, [])

  return (
    <div className='flex flex-col items-center justify-center text-lg'>
      <AiSectionWelcome />
      <AiSectionAbout />
      <AiSectionCompanion />
      <AiSectionPersonalized />
      <AiSectionNightPlanner />
      <GetUpdate />

    </div>
  )
}
