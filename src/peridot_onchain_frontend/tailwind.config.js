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
        "background_disabled": "#333333",
        "text": "var(--text)",
        "text_disabled": "gray",

        "shadow_primary": "#0F120F",
        "shadow_secondary": "#2A3B30",

        // danger
        "danger": "#c5604c",
        "warning": "#deb887",
      },
      lineHeight: {
        'fluid-h1': 'clamp(7rem, 15vw, 17rem)',
        'fluid-h2': 'clamp(2.5rem, 6vw, 6rem)',
        'fluid-h3': 'clamp(1.5rem, 3vw, 3.5rem)',

        'fluid-xl': 'clamp(1.7rem, 3vw, 2.5rem)',

      },
      backgroundImage: {
        'hero-pattern': "url('/assets/bg-text.gif')",
      },
      fontSize: {
        'fluid-h1': 'clamp(5rem, 15vw, 15rem)',
        'fluid-h2': 'clamp(2rem, 5vw, 5rem)',
        'fluid-h3': 'clamp(1rem, 3vw, 3rem)',

        'fluid-sm': 'clamp(0.8rem, 1vw, 1rem)',
        'fluid-base': 'clamp(1rem, 1.5vw, 1.2rem)',
        'fluid-lg': 'clamp(1.2rem, 2vw, 1.5rem)',
        'fluid-xl': 'clamp(1.5rem, 3vw, 2rem)',
      }
    },
  },
  plugins: [],
}

