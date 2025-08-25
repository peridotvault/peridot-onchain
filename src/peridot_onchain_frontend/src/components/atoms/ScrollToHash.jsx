// src/components/ScrollToHash.jsx
import { useEffect } from "react";
import { useLocation } from "react-router-dom";

export default function ScrollToHash() {
    const { pathname, hash } = useLocation();

    useEffect(() => {
        // scroll ke atas saat ganti halaman tanpa hash
        if (!hash) {
            window.scrollTo({ top: 0, behavior: "smooth" });
            return;
        }
        // scroll ke elemen dengan id = hash (tanpa #)
        const id = hash.replace("#", "");
        const el = document.getElementById(id);
        if (el) {
            // tunggu layout ter-render
            setTimeout(() => {
                el.scrollIntoView({ behavior: "smooth", block: "start" });
            }, 0);
        }
    }, [pathname, hash]);

    return null;
}
