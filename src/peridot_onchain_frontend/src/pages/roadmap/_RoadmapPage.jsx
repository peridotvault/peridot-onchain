import React, { useEffect } from 'react'
import { RoadmapSectionWelcome } from './RoadmapSectionWelcome'
import { RoadmapSectionContent } from './RoadmapSectionContent'

export const RoadmapPage = () => {
  useEffect(() => {
    window.scrollTo(0, 0);

  }, [])

  return (
    <div>
      <RoadmapSectionWelcome />
      <RoadmapSectionContent />

    </div>
  )
}
