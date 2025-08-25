import { useEffect, useRef, useState, useId } from "react";

const useDarkMode = () => {
    const [isDark, setIsDark] = useState(false);
    useEffect(() => {
        if (typeof window === "undefined") return;
        const mq = window.matchMedia("(prefers-color-scheme: dark)");
        setIsDark(mq.matches);
        const handler = e => setIsDark(e.matches);
        mq.addEventListener("change", handler);
        return () => mq.removeEventListener("change", handler);
    }, []);
    return isDark;
};

const GlassSurface = ({
    children,
    // width = 200,
    // height = 80,
    borderRadius = 20,
    borderWidth = 0.07,
    brightness = 50,
    opacity = 0.93,
    blur = 11,
    displace = 0,
    backgroundOpacity = 0,
    saturation = 1,
    distortionScale = -180,
    redOffset = 0,
    greenOffset = 10,
    blueOffset = 20,
    xChannel = "R",
    yChannel = "G",
    mixBlendMode = "difference",
    className = "",
    style = {},
}) => {
    const uniqueId = useId().replace(/:/g, "-");
    const filterId = `glass-filter-${uniqueId}`;
    const redGradId = `red-grad-${uniqueId}`;
    const blueGradId = `blue-grad-${uniqueId}`;

    const containerRef = useRef(null);
    const feImageRef = useRef(null);
    const redChannelRef = useRef(null);
    const greenChannelRef = useRef(null);
    const blueChannelRef = useRef(null);
    const gaussianBlurRef = useRef(null);

    const isDarkMode = useDarkMode();

    const generateDisplacementMap = () => {
        const rect = containerRef.current?.getBoundingClientRect();
        const actualWidth = rect?.width || 400;
        const actualHeight = rect?.height || 200;
        const edgeSize = Math.min(actualWidth, actualHeight) * (borderWidth * 0.5);

        const svgContent = `
      <svg viewBox="0 0 ${actualWidth} ${actualHeight}" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <linearGradient id="${redGradId}" x1="100%" y1="0%" x2="0%" y2="0%">
            <stop offset="0%" stop-color="#0000"/>
            <stop offset="100%" stop-color="red"/>
          </linearGradient>
          <linearGradient id="${blueGradId}" x1="0%" y1="0%" x2="0%" y2="100%">
            <stop offset="0%" stop-color="#0000"/>
            <stop offset="100%" stop-color="blue"/>
          </linearGradient>
        </defs>
        <rect x="0" y="0" width="${actualWidth}" height="${actualHeight}" fill="black"></rect>
        <rect x="0" y="0" width="${actualWidth}" height="${actualHeight}" rx="${borderRadius}" fill="url(#${redGradId})" />
        <rect x="0" y="0" width="${actualWidth}" height="${actualHeight}" rx="${borderRadius}" fill="url(#${blueGradId})" style="mix-blend-mode: ${mixBlendMode}" />
        <rect x="${edgeSize}" y="${edgeSize}" width="${actualWidth - edgeSize * 2}" height="${actualHeight - edgeSize * 2}" rx="${borderRadius}" fill="hsl(0 0% ${brightness}% / ${opacity})" style="filter:blur(${blur}px)" />
      </svg>
    `;
        return `data:image/svg+xml,${encodeURIComponent(svgContent)}`;
    };

    const updateDisplacementMap = () => {
        if (feImageRef.current) {
            feImageRef.current.setAttribute("href", generateDisplacementMap());
        }
    };

    // apply filter params & update map
    useEffect(() => {
        updateDisplacementMap();
        [
            { ref: redChannelRef, offset: redOffset },
            { ref: greenChannelRef, offset: greenOffset },
            { ref: blueChannelRef, offset: blueOffset },
        ].forEach(({ ref, offset }) => {
            if (ref.current) {
                ref.current.setAttribute("scale", String(distortionScale + offset));
                ref.current.setAttribute("xChannelSelector", xChannel);
                ref.current.setAttribute("yChannelSelector", yChannel);
            }
        });
        if (gaussianBlurRef.current) {
            gaussianBlurRef.current.setAttribute("stdDeviation", String(displace));
        }
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [
        borderRadius, borderWidth,
        brightness, opacity, blur, displace, distortionScale,
        redOffset, greenOffset, blueOffset, xChannel, yChannel, mixBlendMode
    ]);

    // resize observer (sekali saja)
    useEffect(() => {
        if (!containerRef.current) return;
        const ro = new ResizeObserver(() => setTimeout(updateDisplacementMap, 0));
        ro.observe(containerRef.current);
        return () => ro.disconnect();
    }, []);

    // ensure update setelah width/height berubah
    useEffect(() => {
        setTimeout(updateDisplacementMap, 0);
    }, []);

    const supportsSVGFilters = () => {
        const isWebkit = /Safari/.test(navigator.userAgent) && !/Chrome/.test(navigator.userAgent);
        const isFirefox = /Firefox/.test(navigator.userAgent);
        if (isWebkit || isFirefox) return false;
        const div = document.createElement("div");
        div.style.backdropFilter = `url(#${filterId})`;
        return div.style.backdropFilter !== "";
    };

    const supportsBackdropFilter = () => {
        if (typeof window === "undefined") return false;
        return CSS.supports("backdrop-filter", "blur(10px)");
    };

    const getContainerStyles = () => {
        const baseStyles = {
            ...style,
            borderRadius: `${borderRadius}px`,
            "--glass-frost": backgroundOpacity,
            "--glass-saturation": saturation,
        };
        const svgSupported = supportsSVGFilters();
        const backdropFilterSupported = supportsBackdropFilter();

        if (svgSupported) {
            return {
                ...baseStyles,
                background: isDarkMode
                    ? `hsl(0 0% 0% / ${backgroundOpacity})`
                    : `hsl(0 0% 100% / ${backgroundOpacity})`,
                backdropFilter: `url(#${filterId}) saturate(${saturation})`,
                boxShadow: isDarkMode
                    ? `0 0 2px 1px color-mix(in oklch, white, transparent 65%) inset,
             0 0 10px 4px color-mix(in oklch, white, transparent 85%) inset`
                    : `0 0 2px 1px color-mix(in oklch, black, transparent 85%) inset,
             0 0 10px 4px color-mix(in oklch, black, transparent 90%) inset`,
            };
        }
        if (isDarkMode) {
            if (!backdropFilterSupported) {
                return {
                    ...baseStyles,
                    background: "rgba(0, 0, 0, 0.4)",
                    border: "1px solid rgba(255, 255, 255, 0.2)",
                };
            }
            return {
                ...baseStyles,
                background: "rgba(255, 255, 255, 0.1)",
                backdropFilter: "blur(12px) saturate(1.8) brightness(1.2)",
                WebkitBackdropFilter: "blur(12px) saturate(1.8) brightness(1.2)",
                border: "1px solid rgba(255, 255, 255, 0.2)",
            };
        }
        if (!backdropFilterSupported) {
            return {
                ...baseStyles,
                background: "rgba(255, 255, 255, 0.4)",
                border: "1px solid rgba(255, 255, 255, 0.3)",
            };
        }
        return {
            ...baseStyles,
            background: "rgba(255, 255, 255, 0.25)",
            backdropFilter: "blur(12px) saturate(1.8) brightness(1.1)",
            WebkitBackdropFilter: "blur(12px) saturate(1.8) brightness(1.1)",
            border: "1px solid rgba(255, 255, 255, 0.3)",
        };
    };

    return (
        <div
            ref={containerRef}
            className={`relative flex items-center justify-center overflow-hidden transition-opacity duration-[260ms] ease-out ${className}`}
            style={getContainerStyles()}
        >
            <svg className="w-full h-full pointer-events-none absolute inset-0 opacity-0 -z-10" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <filter id={filterId} colorInterpolationFilters="sRGB" x="0%" y="0%" width="100%" height="100%">
                        <feImage ref={feImageRef} x="0" y="0" width="100%" height="100%" preserveAspectRatio="none" result="map" />
                        <feDisplacementMap ref={redChannelRef} in="SourceGraphic" in2="map" result="dispRed" />
                        <feColorMatrix in="dispRed" type="matrix" values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0" result="red" />
                        <feDisplacementMap ref={greenChannelRef} in="SourceGraphic" in2="map" result="dispGreen" />
                        <feColorMatrix in="dispGreen" type="matrix" values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0" result="green" />
                        <feDisplacementMap ref={blueChannelRef} in="SourceGraphic" in2="map" result="dispBlue" />
                        <feColorMatrix in="dispBlue" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0" result="blue" />
                        <feBlend in="red" in2="green" mode="screen" result="rg" />
                        <feBlend in="rg" in2="blue" mode="screen" result="output" />
                        <feGaussianBlur ref={gaussianBlurRef} in="output" stdDeviation="0.7" />
                    </filter>
                </defs>
            </svg>

            <div className="w-full h-full flex items-center justify-center p-2 rounded-[inherit]  relative z-10">
                {children}
            </div>
        </div>
    );
};

export default GlassSurface;
