import { useRef, useLayoutEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger);

const clamp01 = (n) => Math.min(1, Math.max(0, n));

const AnimatedContent = ({
    children,
    distance = 100,
    direction = "vertical",  // "horizontal" | "vertical"
    reverse = false,
    duration = 0.8,
    ease = "power3.out",
    initialOpacity = 0,
    animateOpacity = true,
    scale = 1,
    threshold = 0.1,         // 0..1
    delay = 0,
    onComplete,
    mode = "toggle",         // "toggle" | "scrub"
}) => {
    const ref = useRef(null);

    useLayoutEffect(() => {
        const el = ref.current;
        if (!el) return;

        // scope GSAP ke elemen ini (handle StrictMode & cleanup otomatis)
        const ctx = gsap.context(() => {
            const axis = direction === "horizontal" ? "x" : "y";

            // Responsif: jarak animasi berbeda per breakpoint
            const mm = gsap.matchMedia();
            mm.add(
                {
                    desktop: "(min-width: 1025px)",
                    tablet: "(min-width: 641px) and (max-width: 1024px)",
                    phone: "(max-width: 640px)",
                },
                (context) => {
                    const { desktop, tablet, phone } = context.conditions;
                    const dist = desktop ? distance : tablet ? distance * 0.7 : distance * 0.5;

                    const t = clamp01(threshold);
                    const startPct = (1 - t) * 100; // ex: t=0.1 -> 90%
                    const start = `top ${startPct}%`;

                    // scrubbing: pakai jarak piksel biar stabil di iPad (toolbar dinamis)
                    const scrubEndPx = Math.max(window.innerHeight * 0.25, 150);

                    // state awal
                    gsap.set(el, {
                        [axis]: reverse ? -dist : dist,
                        scale,
                        opacity: animateOpacity ? initialOpacity : 1,
                        willChange: "transform, opacity",
                    });

                    const tween = gsap.to(el, {
                        [axis]: 0,
                        scale: 1,
                        opacity: 1,
                        duration,
                        ease,
                        delay,
                        onComplete,
                        scrollTrigger: {
                            trigger: el,
                            start,
                            ...(mode === "scrub"
                                ? { scrub: 0.25, end: `+=${scrubEndPx}` }  // <= stabil untuk iPad
                                : { toggleActions: "play none play none" }),
                            invalidateOnRefresh: true,
                        },
                    });

                    // iPad/orientation & font load -> refresh
                    const onOrient = () => ScrollTrigger.refresh();
                    const onLoad = () => ScrollTrigger.refresh();
                    window.addEventListener("orientationchange", onOrient);
                    window.addEventListener("load", onLoad);

                    return () => {
                        window.removeEventListener("orientationchange", onOrient);
                        window.removeEventListener("load", onLoad);
                        tween.scrollTrigger && tween.scrollTrigger.kill();
                        tween.kill();
                    };
                }
            );
        }, ref);

        return () => ctx.revert();
    }, [
        distance,
        direction,
        reverse,
        duration,
        ease,
        initialOpacity,
        animateOpacity,
        scale,
        threshold,
        delay,
        onComplete,
        mode,
    ]);

    return (
        <div ref={ref} className="w-full flex justify-center">
            {children}
        </div>
    );
};

export default AnimatedContent;
