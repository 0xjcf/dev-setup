// postcss.config.mjs - Use .mjs for ES module syntax
const config = {
  plugins: [
    // Use the array format expected by create-next-app
    // Autoprefixer is implicitly included when needed by Tailwind
    '@tailwindcss/postcss'
  ],
};

export default config; 