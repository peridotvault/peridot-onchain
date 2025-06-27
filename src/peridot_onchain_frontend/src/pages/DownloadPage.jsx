import React, { useEffect, useState } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faApple, faWindows } from '@fortawesome/free-brands-svg-icons';

export const DownloadPage = () => {
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
        <div className='w-screen h-screen flex flex-col items-center justify-center'>
            <div className="flex justify-center items-center gap-6">
                {isMac ? (
                    <a href='https://drive.google.com/file/d/1C9c25RUvqGoKlVTq-7Rw-i8YCCMHQXDU/view?usp=sharing' target='_blank' className='py-3 px-6 rounded-xl bg-accent_secondary flex justify-center items-center gap-3 hover:scale-110 duration-300'>
                        <FontAwesomeIcon icon={faApple} />
                        <p>Download for Mac</p>
                    </a>
                ) : (
                    isWindows ? (
                        <a href='https://drive.google.com/file/d/1eGa9PnxW39GtpITtUTj2ddi1tTblTHs-/view?usp=sharing' target='_blank' className='py-3 px-6 rounded-xl bg-accent_secondary flex justify-center items-center gap-3 hover:scale-110 duration-300'>
                            <FontAwesomeIcon icon={faWindows} />
                            <p>Download for Windows</p>
                        </a>
                    ) : (
                        <div className='shadow-xl shadow-accent_primary/30 py-2 px-4 rounded-xl ring-1 ring-accent_primary/30 flex gap-3 items-center'>
                            <p>Now Just Available on </p>
                            <FontAwesomeIcon icon={faApple} /> and
                            <FontAwesomeIcon icon={faWindows} />
                        </div>
                    )
                )}
            </div>
        </div>
    )
}
