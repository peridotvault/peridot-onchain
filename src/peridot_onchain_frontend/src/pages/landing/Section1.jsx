import React, { useEffect, useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faApple, faWindows } from '@fortawesome/free-brands-svg-icons';

export const Section1 = () => {
    const [isMac, setIsMac] = useState(false);
    const [isWindows, setIsWindows] = useState(false);

    useEffect(() => {
        const userAgent = navigator.userAgent;
        if (userAgent.includes('Mac')) {
            setIsMac(true);
        } else if (userAgent.includes('Windows')) {
            setIsWindows(true);
        }
    }, []);

    return (
        <section className="flex w-full p-4">
            <div className="relative w-full flex justify-center overflow-hidden rounded-2xl">
                <div className="max-w-[1200px] flex justify-center items-center px-8 h-[80dvh] ">
                    <div className="w-full text-center flex flex-col gap-6 max-md:gap-4 ">
                        <div className="mb-5 ">
                            <label className='shadow-xl shadow-accent_primary/30 py-2 px-4 rounded-lg ring-1 ring-accent_primary/30 text-base max-md:text-sm'>Peridot is now in Alpha version</label>
                        </div>
                        <h1 className='text-6xl font-bold max-md:text-3xl'>Intelligent Decentralized Gaming</h1>
                        <p className='text-xl max-w-[50rem] max-md:text-base'>Your next gaming era starts here personalized by AI and powered by blockchain. PeridotVault gives you control, simplicity, and freedom.</p>
                        <div className="flex justify-center items-center gap-6">
                            {isMac ? (
                                <a href='https://drive.google.com/file/d/1C9c25RUvqGoKlVTq-7Rw-i8YCCMHQXDU/view?usp=sharing' target='_blank' className='py-3 px-6 rounded-xl bg-accent_secondary flex justify-center items-center gap-3 hover:scale-110 duration-300 max-md:text-base'>
                                    <FontAwesomeIcon icon={faApple} />
                                    <p>Download for Mac</p>
                                </a>
                            ) : (
                                isWindows ? (
                                    <a href='https://drive.google.com/file/d/1eGa9PnxW39GtpITtUTj2ddi1tTblTHs-/view?usp=sharing' target='_blank' className='py-3 px-6 rounded-xl bg-accent_secondary flex justify-center items-center gap-3 hover:scale-110 duration-300 max-md:text-base'>
                                        <FontAwesomeIcon icon={faWindows} />
                                        <p>Download for Windows</p>
                                    </a>
                                ) : (
                                    <div className='shadow-xl shadow-accent_primary/30 py-2 px-4 rounded-xl ring-1 ring-accent_primary/30 flex gap-3 items-center max-md:text-base'>
                                        <p>Now Just Available on </p>
                                        <FontAwesomeIcon icon={faApple} /> and
                                        <FontAwesomeIcon icon={faWindows} />
                                    </div>
                                )
                            )}
                        </div>
                    </div>
                </div>

                <video
                    autoPlay
                    draggable={false}
                    muted
                    loop
                    className="absolute -z-20 w-full h-full top-0 left-0 object-cover"
                >
                    <source src="https://res.cloudinary.com/dcf3oktvs/video/upload/v1743225301/hb1b0kqgmkjlpy9qglzy.mp4" />
                </video>

                <div className="w-full h-full bg-background_primary opacity-30 absolute bottom-0 -z-10"></div>
            </div>
        </section>
    )
}
