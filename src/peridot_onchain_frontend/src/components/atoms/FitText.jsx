import React, { useRef, useState, useLayoutEffect } from "react";

/**
 * Auto-fit single-line text to its container width (no wrap).
 * - Tanpa dependency
 * - Reaktif ke resize container (ResizeObserver)
 */
export default function FitText({
    children,
    className = "",
    min = 12,   // px
    max = 256,  // px
    stepLimit = 4, // berapa kali iterasi penyesuaian (hemat)
    style = {},
}) {
    const containerRef = useRef(null);
    const measureRef = useRef(null);
    const [fontSize, setFontSize] = useState(max);

    const measureAndFit = () => {
        const el = containerRef.current;
        const span = measureRef.current;
        if (!el || !span) return;

        // Mulai dari ukuran sekarang, ukur rasio
        // Pastikan sementara tidak ter-clip
        span.style.fontSize = `${max}px`;

        // Force reflow, dapatkan ukuran asli teks
        const textWidth = span.scrollWidth;
        const boxWidth = el.clientWidth;

        if (boxWidth <= 0 || textWidth <= 0) return;

        // Hitung fontSize target linear dari rasio
        let target = Math.max(min, Math.min(max, (boxWidth / textWidth) * max));

        // Iterasi kecil untuk akurasi (karena metrik font kadang tricky)
        for (let i = 0; i < stepLimit; i++) {
            span.style.fontSize = `${target}px`;
            const w = span.scrollWidth;
            if (w === 0) break;
            const ratio = boxWidth / w;
            const next = target * ratio;

            // Jika perubahan sangat kecil, hentikan
            if (Math.abs(next - target) < 0.5) {
                target = next;
                break;
            }
            target = Math.max(min, Math.min(max, next));
        }

        setFontSize(target);
    };

    useLayoutEffect(() => {
        measureAndFit();

        const ro = new ResizeObserver(() => measureAndFit());
        if (containerRef.current) ro.observe(containerRef.current);

        // juga dengarkan perubahan font/zoom (opsional)
        const onResize = () => measureAndFit();
        window.addEventListener("resize", onResize);

        return () => {
            ro.disconnect();
            window.removeEventListener("resize", onResize);
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    // Re-fit jika children berubah
    useLayoutEffect(() => {
        measureAndFit();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [children]);

    return (
        <div
            ref={containerRef}
            className={`w-full overflow-hidden ${className}`}
            style={{ ...style }}
        >
            {/* Span pengukur & sekaligus yang ditampilkan (single-line) */}
            <span
                ref={measureRef}
                className="block whitespace-nowrap"
                style={{
                    display: "block",
                    lineHeight: 1.05,
                    fontSize: `${fontSize}px`,
                    transform: "translateZ(0)", // hint perf
                }}
            >
                {children}
            </span>
        </div>
    );
}
