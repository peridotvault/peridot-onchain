import React from 'react'
import { Link } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowRight } from '@fortawesome/free-solid-svg-icons';
import StarBorder from './StarBorder';

export const DownloadComponent = () => {
    const linkToDrive = "https://drive.google.com/drive/folders/1KwggYhpptdkMv2O9VmZPY5mYSV1jieum?usp=sharing"

    return (
        <Link to={linkToDrive} target='_blank' >
            <StarBorder speed="2s" className='py-3 px-6 bg-accent_secondary to-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group'>
                <p >Download Now</p>
                <FontAwesomeIcon icon={faArrowRight} className='group-hover:-rotate-45 duration-300' />
            </StarBorder>
        </Link>
    )
}
