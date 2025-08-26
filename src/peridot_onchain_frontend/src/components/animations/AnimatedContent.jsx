import { useRef, useLayoutEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

const AnimatedContent = ({
    children,
    distance = 100,
    direction = "vertical",
    reverse = false,
    duration = 0.8,
    ease = "power3.out",
    initialOpacity = 0,
    animateOpacity = true,
    scale = 1,
    threshold = 0.1,
    delay = 0,
    onComplete,
    mode = "toggle", // "toggle" (default) atau "scrub"
}) => {
    const ref = useRef(null);

    useLayoutEffect(() => {
        const el = ref.current;
        if (!el) return;

        const axis = direction === "horizontal" ? "x" : "y";
        const offset = reverse ? -distance : distance;
        const startPct = (1 - threshold) * 100;

        // state awal
        gsap.set(el, {
            [axis]: offset,
            scale,
            opacity: animateOpacity ? initialOpacity : 1,
        });

        // tween + ScrollTrigger
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
                start: `top ${startPct}%`,
                // MODE "toggle": play saat masuk, reverse saat leave & saat enter balik dari atas
                ...(mode === "toggle"
                    ? { toggleActions: "play reverse play reverse" }
                    // MODE "scrub": animasi mengikuti scroll (bolak-balik mulus)
                    : {
                        scrub: 0.25,                  // gesek halus
                        end: `top ${Math.max(startPct - 30, 0)}%`, // rentang kecil cukup
                    }),
                // jangan pakai once, supaya bisa bolak-balik
                once: false,
                // invalidate ukuran saat refresh/resize
                invalidateOnRefresh: true,
            },
        });

        // cleanup: kill tween & trigger milik tween ini saja
        return () => {
            if (tween.scrollTrigger) tween.scrollTrigger.kill();
            tween.kill();
        };
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
        <div className="w-full flex justify-center" ref={ref}>
            {children}
        </div>
    );
};

export default AnimatedContent;
