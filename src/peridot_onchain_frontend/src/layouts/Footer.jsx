import { Link } from "react-router-dom";
import FitText from "../components/atoms/FitText";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faDiscord, faGithub, faInstagram, faTelegram, faXTwitter } from "@fortawesome/free-brands-svg-icons";

export const Footer = () => {

    return (
        <footer className="flex justify-center ">
            <div className="max-w-[1200px] px-8 w-full flex flex-col pt-24 pb-8 gap-10 ">





                <div className="relative">
                    <FitText min={24} max={224} className="mx-auto text-background_disabled">
                        <span className="font-bold">Peridot</span>
                        <span className="font-light">Vault</span>
                    </FitText>
                    <div className="absolute w-full h-full bg-gradient-to-t from-background_primary top-0 left-0"></div>
                </div>

                <hr className="opacity-20 border-t border-text_disabled" />

                {/* content */}
                <div className="flex gap-6 justify-end max-md:justify-start duration-300">
                    <Link to={"https://www.instagram.com/peridotvault/"} target="_blank" className="text-2xl"><FontAwesomeIcon icon={faInstagram} /></Link>
                    <Link to={"https://x.com/peridotvault"} target="_blank" className="text-2xl"><FontAwesomeIcon icon={faXTwitter} /></Link>
                    <Link to={"https://discord.com/invite/uBW4dvTR5E"} target="_blank" className="text-2xl"><FontAwesomeIcon icon={faDiscord} /></Link>
                    <Link to={"https://github.com/peridotvault"} target="_blank" className="text-2xl"><FontAwesomeIcon icon={faGithub} /></Link>
                    <Link to={"https://t.me/peridotvault"} target="_blank" className="text-2xl"><FontAwesomeIcon icon={faTelegram} /></Link>
                </div>

                {/* terms  */}
                <div className="w-full flex max-md:flex-col gap-6 max-md:gap-2 justify-between duration-300">
                    <span className="text-text_disabled">{new Date().getFullYear()} &copy; Antigane. All rights reserved.</span>
                    <div className="flex gap-6">
                        <Link >Privacy Policy</Link>
                        <Link >Terms and Conditions</Link>
                    </div>
                </div>
            </div>
        </footer>
    );
}