import React, { useState, useEffect, useRef } from 'react';
import StarBorder from '../atoms/StarBorder';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronRight } from '@fortawesome/free-solid-svg-icons';

export const FloatingActionButton = () => {
  const [chatDisplayed, setChatDisplayed] = useState(false);
  const [messages, setMessages] = useState([
    {
      id: 1,
      sender: 'ai',
      text: 'Hi, how can I help you?',
    },
    {
      id: 2,
      sender: 'human',
      text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tellus enim, vestibulum ut laoreet ut, gravida quis mi.',
    },
    // Add more initial messages here if needed
  ]);
  const [inputValue, setInputValue] = useState('');
  const chatRef = useRef(null);
  const messagesEndRef = useRef(null);

  // Function to scroll to the bottom of the messages container
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  // Effect to scroll down whenever a new message is added
  useEffect(() => {
    scrollToBottom();
  }, [messages]);


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

  // Function to handle form submission
  const handleSendMessage = (e) => {
    e.preventDefault();
    if (inputValue.trim() === '') return;

    // Add the user's message to the list
    const userMessage = {
      id: Date.now(), // Use a more robust unique ID in a real app
      sender: 'human',
      text: inputValue,
    };
    setMessages((prevMessages) => [...prevMessages, userMessage]);
    setInputValue(''); // Clear the input field

    // Simulate an AI response after a short delay
    setTimeout(() => {
      const aiResponse = {
        id: Date.now() + 1,
        sender: 'ai',
        text: 'This is a simulated response. I received your message!',
      };
      setMessages((prevMessages) => [...prevMessages, aiResponse]);
    }, 1000);
  };

  return (
    <div ref={chatRef} className="fixed bottom-20 right-20 flex flex-col items-end">
      {/* --- CHAT WINDOW --- */}
      <div className={chatDisplayed ? 'bg-white/90 backdrop-blur-md w-[512px] h-[640px] mb-4 rounded-xl flex flex-col overflow-hidden shadow-2xl' : 'hidden'}>
        
        {/* Header */}
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

        {/* Messages list - Renders messages dynamically */}
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
          {/* Empty div to act as a reference for scrolling */}
          <div ref={messagesEndRef} />
        </div>

        {/* Chat Input */}
        <div className='border-t-2 border-t-black/25 p-4'>
          <form className='flex items-center gap-4' onSubmit={handleSendMessage}>
            <input
              type="text"
              placeholder="Type your message..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              className="flex-1 bg-transparent border border-black/30 rounded-lg px-4 py-2 text-black placeholder:text-black/50 focus:outline-none focus:ring-2 focus:ring-accent_secondary"
            />
            <button className='bg-accent_secondary text-white rounded-lg p-2 w-12 h-10 flex items-center justify-center hover:bg-opacity-80 transition-colors' type='submit'>
              <FontAwesomeIcon icon={faChevronRight} />
            </button>
          </form>
        </div>
      </div>
      
      {/* --- FLOATING BUTTON --- */}
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