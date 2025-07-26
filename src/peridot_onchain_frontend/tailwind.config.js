/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        "accent_primary": "#90EE90",
        "accent_secondary": "#4D8A6A",

        "background_primary": "var(--background_primary)",
        "background_secondary": "var(--background_secondary)",

        "background_primary_opacity": "#1c1f1d71",

        "background_disabled": "#333333",
        "text": "var(--text)",
        "text_disabled": "gray",

        "shadow_primary": "#0F120F",
        "shadow_secondary": "#2A3B30",

        // danger
        "danger": "#c5604c",
        "warning": "#deb887",
      },
      backgroundImage: {
        'hero-pattern': "url('/assets/bg-text.gif')",
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',

      },
      boxShadow: {
        // black background
        // large black background
        'flat-lg': '27px 27px 55px #0c0d0c, -27px -27px 55px #2c312e',
        'sunken-lg': 'inset 27px 27px 55px #0c0d0c, inset -27px -27px 55px #2c312e',
        // small 
        'flat-sm': '3px 3px 6px #0c0d0c, -3px -3px 6px #2c312e',
        "sunken-sm": "inset 5px 5px 10px #0c0d0c, inset -5px -5px 10px #2c312e",
        "arise-sm": "inset 2px 2px 5px #0c0d0c,inset -2px -2px 5px #2c312e, 2px 2px 5px #0c0d0c, -2px -2px 5px #2c312e",

        // green background 
        "sunken-md-green": "inset 5px 5px 10px #2e483a, inset -5px -5px 10px #3e624e",
      },
      animation: {
        'star-movement-bottom': 'star-movement-bottom linear infinite alternate',
        'star-movement-top': 'star-movement-top linear infinite alternate',
      },
      keyframes: {
        'star-movement-bottom': {
          '0%': { transform: 'translate(0%, 0%)', opacity: '1' },
          '100%': { transform: 'translate(-100%, 0%)', opacity: '0' },
        },
        'star-movement-top': {
          '0%': { transform: 'translate(0%, 0%)', opacity: '1' },
          '100%': { transform: 'translate(100%, 0%)', opacity: '0' },
        },
      },
    },
  },
  plugins: [
    require('tailwind-scrollbar-hide')
  ],
}
