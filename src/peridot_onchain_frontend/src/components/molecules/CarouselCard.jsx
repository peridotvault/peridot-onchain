import React, { useEffect, useState } from "react";

const carouselItems = [
    { alt: "Hollow Knight", img_url: "./img/hn-games.png" },
    { alt: "A Space for the unbound", img_url: "./img/asftu-games.jpg" },
    { alt: "God Of War", img_url: "./img/gow-games.jpg" },
    { alt: "Axie Infinity", img_url: "./img/ai-games.png" },
    { alt: "Fifa Rivals", img_url: "./img/fr-games.png" },
    { alt: "Hollow Knight", img_url: "./img/hn-games.png" },
    { alt: "A Space for the unbound", img_url: "./img/asftu-games.jpg" },
    { alt: "God Of War", img_url: "./img/gow-games.jpg" },
    { alt: "Axie Infinity", img_url: "./img/ai-games.png" },
    { alt: "Fifa Rivals", img_url: "./img/fr-games.png" },

];

export const CarouselCard = () => {
    const itemsToShow = 3;
    const [index, setIndex] = useState(0);
    const totalItems = carouselItems.length;

    useEffect(() => {
        const interval = setInterval(() => {
            setIndex((prev) => (prev + 1) % totalItems);
        }, 2000); // every 2 seconds

        return () => clearInterval(interval);
    }, [totalItems]);

    // duplicate first few cards to allow smooth looping
    const extendedItems = [...carouselItems, ...carouselItems.slice(0, itemsToShow)];

    const getTranslateX = () => {
        return `-${index * (500 / itemsToShow)}px`;
    };

    return (
        <div className="relative overflow-hidden">
            {/* Fade sides */}
            <div className="pointer-events-none absolute left-0 top-0 h-full w-24 bg-gradient-to-r from-background_primary z-10" />
            <div className="pointer-events-none absolute right-0 top-0 h-full w-24 bg-gradient-to-l from-background_primary z-10" />

            {/* Carousel Track */}
            <div className="overflow-hidden w-full">
                <div
                    className="flex transition-transform duration-700 ease-in-out gap-6"
                    style={{
                        width: `${(extendedItems.length / itemsToShow) * 200}px`,
                        transform: `translateX(${getTranslateX()})`,
                    }}
                >
                    {extendedItems.map((item, idx) => (
                        <div
                            key={idx}
                            className="w-[200px] flex-shrink-0"
                        >
                            <div className="bg-background_secondary rounded-2xl shadow-lg overflow-hidden h-full aspect-[3/4] flex flex-col justify-between">
                                <img draggable={false} src={item.img_url} className="w-full h-full object-cover opacity-70" alt={item.alt} />
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};
