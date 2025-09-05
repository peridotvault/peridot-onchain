import React, { useState, useEffect, useRef } from 'react';
import StarBorder from '../atoms/StarBorder';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'

export const FloatingActionButton = () => {
  const [chatDisplayed, setChatDisplayed] = useState(false);
  const chatRef = useRef(null);

  useEffect(() => {
    // Function to handle clicks outside the component
    const handleClickOutside = (event) => {
      // If the ref is attached and the click is outside the referenced element
      if (chatRef.current && !chatRef.current.contains(event.target)) {
        setChatDisplayed(false); // Close the chat
      }
    };

    // Add event listener when the component mounts
    document.addEventListener('mousedown', handleClickOutside);

    // Clean up the event listener when the component unmounts
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <div ref={chatRef} className="fixed bottom-20 right-20 flex flex-col items-end">
      <div className={chatDisplayed ? 'bg-white/90 backdrop-blur-md w-[512px] h-[640px] mb-4 rounded-xl flex flex-col overflow-hidden shadow-2xl' : 'hidden'}>
        
        {/* Header - Stays fixed at the top */}
        <div className='border-b-2 border-b-black/25 p-4'>
          <div className='flex items-center justify-between gap-6'>
            <div>
              <p className='text-black text-2xl font-bold'>Peridot Agent</p>
            </div>
            <div>
              <button className='text-accent_secondary font-extrabold text-2xl' onClick={() => setChatDisplayed(false)}>x</button>
            </div>
          </div>
        </div>

        {/* Messages list - This container will scroll */}
        <div className='flex-1 overflow-y-auto scrollbar-hide p-6 flex flex-col gap-6'>
          {/* AI */}
          <div>
            <p className='font-semibold text-black/60 mb-1'>Peridot Agent</p>
            <div className='bg-black/20 max-w-[416px] p-4 rounded-e-xl rounded-bl-xl'>
              <p className='text-black text-base'>
                Hi, how can I help you?
              </p>
            </div>
          </div>

          {/* Human */}
          <div className='flex flex-col items-end'>
            <p className='font-semibold text-accent_secondary mb-1'>You</p>
            <div className='bg-accent_secondary/50 max-w-[416px] p-4 rounded-s-xl rounded-br-xl'>
              <p className='text-black text-base'>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tellus enim, vestibulum ut laoreet ut, gravida quis mi. Quisque nec sem pretium, ultricies mauris quis, feugiat sem.
              </p>
            </div>
          </div>

          {/* AI */}
          <div>
            <p className='font-semibold text-black/60 mb-1'>Peridot Agent</p>
            <div className='bg-black/20 max-w-[416px] p-4 rounded-e-xl rounded-bl-xl'>
              <p className='text-black text-base'>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tellus enim, vestibulum ut laoreet ut, gravida quis mi.
              </p>
            </div>
          </div>

          {/* Human */}
          <div className='flex flex-col items-end'>
            <p className='font-semibold text-accent_secondary mb-1'>You</p>
            <div className='bg-accent_secondary/50 max-w-[416px] p-4 rounded-s-xl rounded-br-xl'>
              <p className='text-black text-base'>
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tellus enim, vestibulum ut laoreet ut, gravida quis mi. Quisque nec sem pretium, ultricies mauris quis, feugiat sem. Vestibulum ante ipsum primis in faucibus.
              </p>
            </div>
          </div>
        </div>

        {/* Chat Input */}
        <div className='border-t-2 border-t-black/25 p-4'>
          <form className='flex items-center gap-4'>
            <input
              type="text"
              placeholder="Type your message..."
              className="flex-1 bg-transparent border border-black/30 rounded-lg px-4 py-2 text-black placeholder:text-black/50 focus:outline-none focus:ring-2 focus:ring-accent_secondary"
            />
            <button className='bg-accent_secondary text-white rounded-lg p-2 w-12 h-10 flex items-center justify-center hover:bg-opacity-80 transition-colors' type='submit'>
              <FontAwesomeIcon icon={faChevronRight} />
            </button>
          </form>
        </div>
      </div>

      <button onClick={() => setChatDisplayed(!chatDisplayed)}>
        <StarBorder speed='2s' className='py-3 px-6 bg-accent_secondary to-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group'>
          <span className="font-bold">
            Chat with AI
          </span>
        </StarBorder>
      </button>
    </div>
  );
};