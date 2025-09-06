import React, { useState, useEffect, useRef } from 'react';
import StarBorder from '../atoms/StarBorder';
import { peridot_ai } from "declarations/peridot_ai/index.js"
import { Bouncy } from 'ldrs/react'
import 'ldrs/react/Bouncy.css'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'; // Import FontAwesomeIcon
import { faChevronRight } from '@fortawesome/free-solid-svg-icons'; // Import the icon

export const FloatingActionButton = () => {
  const [chatDisplayed, setChatDisplayed] = useState(false);
  const [isAgentResponding, setIsAgentResponding] = useState(false);
  const [messages, setMessages] = useState([]);
  const [inputValue, setInputValue] = useState('');
  const chatRef = useRef(null);
  const messagesEndRef = useRef(null);

  // Function to scroll to the bottom of the messages container
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  // Effect to scroll down whenever a new message or loading indicator appears
  useEffect(() => {
    scrollToBottom();
  }, [messages, isAgentResponding]); // Add isAgentResponding as a dependency

  // Effect for handling clicks outside the chat window
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (chatRef.current && !chatRef.current.contains(event.target)) {
        setChatDisplayed(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleOnChatDisplayed = async () => {
    // Toggle display state first for immediate UI feedback
    setChatDisplayed(prev => !prev);
    
    // Fetch initial message only if chat is being opened and is empty
    if (!chatDisplayed && messages.length === 0) {
      setIsAgentResponding(true);
      const response = await peridot_ai.chat("Hello");
      const aiResponse = {
          id: Date.now() + 1,
          sender: 'ai',
          text: response,
        };
      setMessages([aiResponse]); // Initialize messages with the response
      setIsAgentResponding(false);
    }
  }

  // Function to handle form submission
  const handleSendMessage = async (e) => {
    e.preventDefault();
    if (inputValue.trim() === '' || isAgentResponding) return;

    const userMessage = {
      id: Date.now(), 
      sender: 'human',
      text: inputValue,
    };

    // Add user message and immediately show loading indicator
    setMessages((prevMessages) => [...prevMessages, userMessage]);
    setInputValue(''); 
    setIsAgentResponding(true);

    const response = await peridot_ai.chat(inputValue.trim())
    const aiResponse = {
        id: Date.now() + 1,
        sender: 'ai',
        text: response,
      };
      
    // Replace loading indicator with the actual response
    setMessages((prevMessages) => [...prevMessages, aiResponse]);
    setIsAgentResponding(false);
  };

  return (
    <div ref={chatRef} className="fixed bottom-20 right-20 flex flex-col items-end">
      <div className={chatDisplayed ? 'bg-white/90 backdrop-blur-md w-[512px] h-[640px] mb-4 rounded-xl flex flex-col overflow-hidden shadow-2xl' : 'hidden'}>
        
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

        <div className='flex-1 overflow-y-auto scrollbar-hide p-6 flex flex-col gap-6'>
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex flex-col ${
                message.sender === 'human' ? 'items-end' : 'items-start'
              }`}
            >
              <p className={`font-semibold mb-1 ${
                message.sender === 'human' ? 'text-accent_secondary' : 'text-black/60'
              }`}>
                {message.sender === 'human' ? 'You' : 'Peridot Agent'}
              </p>
              <div className={`max-w-[416px] p-4 ${
                message.sender === 'human'
                  ? 'bg-accent_secondary/50 rounded-s-xl rounded-br-xl'
                  : 'bg-black/20 rounded-e-xl rounded-bl-xl'
              }`}>
                <p className='text-black text-base'>{message.text}</p>
              </div>
            </div>
          ))}

          {/* --- LOADING INDICATOR --- */}
          {/* This block is rendered only when isAgentResponding is true */}
          {isAgentResponding && (
            <div className="flex flex-col items-start">
              <p className="font-semibold mb-1 text-black/60">Peridot Agent</p>
              <div className="max-w-[416px] p-4 bg-black/20 rounded-e-xl rounded-bl-xl flex items-center justify-center">
                <Bouncy
                  size="24"
                  speed="2.5"
                  color="black" 
                />
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        <div className='border-t-2 border-t-black/25 p-4'>
          <form className='flex items-center gap-4' onSubmit={handleSendMessage}>
            <input
              type="text"
              placeholder={isAgentResponding ? "Waiting for response..." : "Type your message..."}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              className="flex-1 bg-transparent border border-black/30 rounded-lg px-4 py-2 text-black placeholder:text-black/50 focus:outline-none focus:ring-2 focus:ring-accent_secondary disabled:bg-black/10"
              disabled={isAgentResponding}
            />
          </form>
        </div>
      </div>
      
      <button onClick={handleOnChatDisplayed}>
        <StarBorder speed='2s' className='py-3 px-6 bg-accent_secondary to-accent_secondary flex justify-center items-center gap-3 hover:bg-white hover:text-black duration-300 max-md:text-base group'>
          <span className="font-bold">
            Chat with AI
          </span>
        </StarBorder>
      </button>
    </div>
  );
};