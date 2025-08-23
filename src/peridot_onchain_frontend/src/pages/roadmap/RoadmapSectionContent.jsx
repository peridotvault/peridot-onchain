import React, { useRef } from 'react'
import SpotlightCard from '../../components/atoms/SpotlightCard'
import roadmapData from "./../../assets/roadmap.json";
import { faCheck, faCircleNotch, faChevronLeft, faChevronRight } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const formatDate = (iso) =>
    new Date(iso).toLocaleDateString(undefined, {
        year: "numeric",
        month: "long",
        day: "numeric",
    });

export const RoadmapSectionContent = () => {
    const data = roadmapData;
    return (
        <div className='w-full flex justify-center px-8 py-24 gap-10'>
            <div className="w-full flex flex-col gap-24">
                {data.sections.map((section, idx) => (
                    <Content key={idx} section={section} />
                ))}
            </div>
        </div>
    )
}

const Content = ({ section }) => {
    const scrollRef = useRef(null);

    const scroll = (dir) => {
        if (scrollRef.current) {
            scrollRef.current.scrollBy({
                left: dir === "left" ? -500 : 500,
                behavior: "smooth",
            });
        }
    };

    return (
        <section className='w-full flex flex-col gap-14 items-center'>
            {/* Judul & deskripsi */}
            <div className="max-w-[1200px] w-full">
                <div className="flex flex-col gap-8 px-8">
                    <h2 className='text-4xl font-bold'>{section.title}</h2>
                    <p className='w-2/3 max-w-[800px] text-xl'>
                        {section.description}
                    </p>
                </div>
            </div>

            {/* Scrollable cards dengan arrow */}
            <div className="relative w-full">
                {/* Left Arrow */}
                <button
                    onClick={() => scroll("left")}
                    className="absolute left-0 top-1/2 -translate-y-1/2 z-10 bg-background_secondary p-3 rounded-full shadow-md hover:bg-background_primary"
                >
                    <FontAwesomeIcon icon={faChevronLeft} className="text-xl" />
                </button>

                {/* Scrollable area */}
                <div
                    ref={scrollRef}
                    className="w-full overflow-x-auto scrollbar-hide scroll-smooth"
                >
                    <div className="max-w-[1200px] mx-auto px-8">
                        <div className="flex gap-8 w-max">
                            {section.items.map((item, idx) => (
                                <SpotlightCard
                                    key={idx}
                                    className={`flex-shrink-0 custom-spotlight-card p-8 rounded-xl aspect-video w-[450px] flex flex-col justify-between ${item.status === "completed" ? "bg-accent_secondary/10" : ""}`}
                                >
                                    <div className="flex justify-between relative">
                                        <div className="flex flex-col gap-2">
                                            <h3 className='text-2xl font-bold'>{item.title}</h3>
                                            {item.status === "completed" && (
                                                <p>
                                                    <span className={"text-success capitalize"}>
                                                        {item.status}
                                                    </span>{" "}
                                                    {formatDate(item.date)}
                                                </p>
                                            )}
                                        </div>
                                        <div className={`w-[50px] absolute right-0 top-0 rounded-full aspect-square flex items-center justify-center text-3xl text-background_primary ${item.status === "completed" ? "border border-success bg-accent_secondary" : "bg-warning"}`}>
                                            <FontAwesomeIcon icon={item.status === "completed" ? faCheck : faCircleNotch} />
                                        </div>
                                    </div>
                                    <div className="flex justify-between items-end">
                                        <p className='text-lg w-2/3'>
                                            {item.description}
                                        </p>
                                        <div className="flex flex-col items-end">
                                            <span className='text-8xl'>{item.featuresCount}</span>
                                            <span>Features</span>
                                        </div>
                                    </div>
                                </SpotlightCard>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Right Arrow */}
                <button
                    onClick={() => scroll("right")}
                    className="absolute right-0 top-1/2 -translate-y-1/2 z-10 bg-background_secondary p-3 rounded-full shadow-md hover:bg-background_primary"
                >
                    <FontAwesomeIcon icon={faChevronRight} className="text-xl" />
                </button>
            </div>
        </section>
    )
}
