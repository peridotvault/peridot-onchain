import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faArrowRight } from "@fortawesome/free-solid-svg-icons";
import { faApple } from "@fortawesome/free-brands-svg-icons";
import StarBorder from "./StarBorder";

// 🔍 Deteksi platform dari userAgent (pure JS)
const detectPlatform = () => {
    if (typeof window === "undefined") return "unknown";

    const ua = window.navigator.userAgent || "";
    const isMac = /Macintosh|Mac OS X/i.test(ua);
    const isIOS = /iPhone|iPad|iPod/i.test(ua);
    const isWindows = /Windows NT/i.test(ua);
    const isAndroid = /Android/i.test(ua);
    const isLinux =
        /Linux/i.test(ua) && !isAndroid && !isMac && !isWindows;

    if (isIOS) return "ios";
    if (isAndroid) return "android";
    if (isWindows) return "windows";
    if (isLinux) return "linux";

    if (isMac) {
        const isArm = /ARM|Apple M1|Apple M2|Apple M3|Apple Silicon/i.test(ua);
        return isArm ? "mac-arm" : "mac-intel";
    }

    return "unknown";
};

export const DownloadComponent = () => {
    const linkMacOsArm64 =
        "https://github.com/peridotvault/peridot-desktop/releases/download/0.0.5/PeridotVault-0.0.5-arm64.dmg";
    const linkMacOs =
        "https://github.com/peridotvault/peridot-desktop/releases/download/0.0.5/PeridotVault-0.0.5.dmg";
    const linkWindows =
        "https://github.com/peridotvault/peridot-desktop/releases/download/0.0.5/PeridotVault-Setup-0.0.5.exe";

    const platform = detectPlatform();
    const isMac = platform === "mac-arm" || platform === "mac-intel";

    // 🖥️ Kalau macOS → tampilkan 2 button: Intel Based & Apple Chip
    if (isMac) {
        const isArm = platform === "mac-arm";

        const baseClasses =
            "py-2 px-6 flex justify-center items-center gap-3 duration-300 max-md:text-sm group";
        const activeClasses = "bg-accent_secondary hover:bg-white hover:text-black";
        const secondaryClasses =
            "bg-transparent border border-accent_secondary hover:bg-accent_secondary hover:text-black";

        return (
            <div className="flex flex-col md:flex-row gap-3">
                {/* Intel Based */}
                <a href={linkMacOs} target="_blank" rel="noreferrer">
                    <StarBorder
                        speed="2s"
                        className={
                            baseClasses +
                            " " +
                            (isArm ? secondaryClasses : activeClasses)
                        }
                    >
                        <FontAwesomeIcon
                            icon={faApple}
                            className="group-hover:-rotate-45 duration-300"
                        />
                        <div className="flex flex-col items-start">
                            <p className="font-medium">Intel Based</p>
                        </div>
                    </StarBorder>
                </a>

                {/* Apple Chip */}
                <a href={linkMacOsArm64} target="_blank" rel="noreferrer">
                    <StarBorder
                        speed="2s"
                        className={
                            baseClasses +
                            " " +
                            (isArm ? secondaryClasses : activeClasses)
                        }
                    >
                        <FontAwesomeIcon
                            icon={faApple}
                            className="group-hover:-rotate-45 duration-300"
                        />
                        <div className="flex flex-col items-start">
                            <p className="font-medium">Apple Chip</p>
                        </div>
                    </StarBorder>
                </a>
            </div>
        );
    }

    // 💻 Kalau Windows → satu button biasa
    if (platform === "windows") {
        return (
            <a href={linkWindows} target="_blank" rel="noreferrer">
                <StarBorder
                    speed="2s"
                    className="py-2 px-6 bg-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group"
                >
                    <FontAwesomeIcon
                        icon={faArrowRight}
                        className="group-hover:translate-x-1 duration-300"
                    />
                    <div className="flex flex-col items-start">
                        <p className="font-medium">Download for Windows</p>
                    </div>
                </StarBorder>
            </a>
        );
    }

    // 🐧📱 Linux, iOS, Android, unknown → belum available
    return (
        <div>
            <StarBorder
                speed="2s"
                className="py-2 px-6 bg-accent_secondary flex flex-col md:flex-row justify-center items-center gap-2 opacity-60 cursor-not-allowed max-md:text-sm"
            >
                <p className="font-medium">not available this device</p>
            </StarBorder>
        </div>
    );
};
