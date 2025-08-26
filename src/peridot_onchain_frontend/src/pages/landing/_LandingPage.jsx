import React, { useEffect } from 'react'
import { Section1 } from './Section1';
import { Section2 } from './Section2';
import { Section3 } from './Section3';
import { SectionGameVault } from './SectionGameVault';
import { GetUpdate } from '../../components/organisms/GetUpdate';
import { SectionTeam } from './SectionTeam';
import { SectionWhitepaperRoadmap } from './SectionWhitepaperRoadmap';
import { SectionNativeWallet } from './SectionNativeWallet';
import ParticlesComponent from '../../components/particles/particles';
import { SectionAI } from './SectionAI';
import { SectionUI } from './SectionUI';
import AnimatedContent from '../../components/animations/AnimatedContent';

export const LandingPage = () => {
    useEffect(() => {
        window.scrollTo(0, 0);

    }, [])

    return (
        <div className='flex flex-col items-center justify-center text-lg'>
            <ParticlesComponent />


            <Section1 />
            <Section2 />
            <Section3 />
            <SectionUI />
            <SectionAI />
            <SectionGameVault />
            <SectionNativeWallet />
            <SectionWhitepaperRoadmap />
            <SectionTeam />
            <GetUpdate />
        </div>
    )
}
