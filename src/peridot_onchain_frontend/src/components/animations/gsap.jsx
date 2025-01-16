import React, { useEffect, useRef, useState } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import LocomotiveScroll from 'locomotive-scroll';
import 'locomotive-scroll/dist/locomotive-scroll.css';

gsap.registerPlugin(ScrollTrigger);

// Navbar color change animation function
export const initNavColorChange = (navRef, locomotiveScrollInstance) => {
    const navbar = navRef.current;
    if (!navbar) return;

    // Create timeline for navbar background
    const tl = gsap.timeline({
        scrollTrigger: {
            trigger: "body",
            start: "top top",
            end: "40px",
            scrub: 0.1,
            onEnter: () => handleImageSwap(true),
            onLeaveBack: () => handleImageSwap(false)
        }
    });

    // Animation for navbar background
    tl.fromTo(navbar, {
        backgroundColor: "transparent",
    }, {
        backgroundColor: "white",
        boxShadow: "0 2px 10px rgba(0, 0, 0, 0.1)",
        duration: 0.05
    });

    // Animation for text color
    const links = navbar.querySelectorAll('a:not(.bg-accent_secondary)');
    links.forEach(link => {
        gsap.fromTo(link, {
            color: "white"
        }, {
            color: "black",
            scrollTrigger: {
                trigger: "body",
                start: "top top",
                end: "40px",
                scrub: 0.1
            }
        });
    });

    // Handle image swap
    const handleImageSwap = (shouldUseDark) => {
        const logo = navbar.querySelector('img');
        if (!logo) return;

        const whiteSrc = logo.getAttribute('data-white-src');
        const darkSrc = logo.getAttribute('data-dark-src');

        if (shouldUseDark && darkSrc) {
            logo.src = darkSrc;
        } else if (whiteSrc) {
            logo.src = whiteSrc;
        }
    };

    return () => {
        ScrollTrigger.getAll().forEach(trigger => trigger.kill());
    };
};

export const SmoothScroll = ({ children, navRef }) => {
    const scrollRef = useRef(null);
    const [locomotiveScroll, setLocomotiveScroll] = useState(null);

    useEffect(() => {
        let locoScroll = null;

        const initScroll = async () => {
            if (!scrollRef.current) return;

            try {
                await new Promise(resolve => setTimeout(resolve, 100));

                locoScroll = new LocomotiveScroll({
                    el: scrollRef.current,
                    smooth: true,
                    multiplier: 1,
                    class: 'is-revealed',
                    lerp: 0.1,
                    reloadOnContextChange: true,
                    smoothMobile: {
                        smooth: true,
                        breakpoint: 0,
                    },
                    tablet: {
                        smooth: true,
                        breakpoint: 0,
                    }
                });

                setLocomotiveScroll(locoScroll);

                // Handle ScrollTrigger integration
                locoScroll.on("scroll", ScrollTrigger.update);

                ScrollTrigger.scrollerProxy(scrollRef.current, {
                    scrollTop(value) {
                        return arguments.length
                            ? locoScroll.scrollTo(value)
                            : locoScroll.scroll.instance.scroll.y;
                    },
                    getBoundingClientRect() {
                        return {
                            top: 0,
                            left: 0,
                            width: window.innerWidth,
                            height: window.innerHeight
                        };
                    },
                    pinType: scrollRef.current.style.transform ? "transform" : "fixed"
                });

                // Initialize navbar color change after locomotive is ready
                if (navRef) {
                    initNavColorChange(navRef, locoScroll);
                }

                // Update scroll on page refresh
                ScrollTrigger.addEventListener("refresh", () => locoScroll.update());
                ScrollTrigger.defaults({ scroller: scrollRef.current });

                // Refresh everything
                setTimeout(() => {
                    locoScroll.update();
                    ScrollTrigger.refresh();
                }, 200);
            } catch (error) {
                console.error('Failed to initialize Locomotive Scroll:', error);
            }
        };

        initScroll();

        return () => {
            if (locoScroll) {
                ScrollTrigger.getAll().forEach(t => t.kill());
                locoScroll.destroy();
                setLocomotiveScroll(null);
            }
        };
    }, [navRef]);

    return (
        <div
            ref={scrollRef}
            data-scroll-container
            className="relative w-full min-h-screen overflow-hidden"
        >
            {children}
        </div>
    );
};

export default {
    SmoothScroll,
    initNavColorChange
};