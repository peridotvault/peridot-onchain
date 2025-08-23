import React from 'react'
import TiltedCard from '../../components/atoms/TiltedCard'

export const SectionTeam = () => {

  const teamLists = [
    {
      image: "./assets/the-founder.png",
      name: "Ranaufal Muha",
      title: "Founder, CEO",
    },
    {
      image: "./assets/the-cofounder.jpeg",
      name: "Michael Eko Hartono Gunawan",
      title: "Co-Founder, CTO",
    },
    {
      image: "./assets/the-designer.png",
      name: "Michael Chandra",
      title: "UI Designer",
    }
  ]

  return (
    <section id='team' className='max-w-[1200px] w-full flex flex-col justify-center px-8 gap-20 py-24'>
      <div className="flex flex-col items-center gap-5">
        <h2 className='text-5xl font-bold '>Meet Our <span className='text-accent_primary'>Team</span></h2>
        <p className='text-xl w-[50rem] text-center'>Passionate Innovators Driving PeridotVault Forward</p>
      </div>
      {/* content  */}
      <div className="flex max-md:flex-col justify-center items-center gap-10">
        {teamLists.map((item, idx) => (
          <div className="aspect-[3/5] max-lg:aspect-[2/5] max-md:aspect-square  duration-300 w-full h-full">
            <TiltedCard
              key={idx}
              imageSrc={item.image}
              altText={item.name}
              captionText={item.title}
              rotateAmplitude={12}
              scaleOnHover={1.1}
              showMobileWarning={false}
              showTooltip={true}
              displayOverlayContent={true}
              overlayContent={
                <div className="p-10 w-full h-full flex flex-col justify-end text-center">
                  <h3 className="text-2xl  font-bold">
                    {item.name}
                  </h3>
                  <p>{item.title}</p>
                </div>
              }
            />
          </div>
        ))}
      </div>
    </section>
  )
}
