import type { Config } from "tailwindcss";

export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        base: "var(--color-base)",
        "base-light": "var(--color-base-light)",
        "base-dark": "var(--color-base-dark)",
        accent: "var(--color-accent)",
        "accent-light": "var(--color-accent-light)",
      },
    },
  },
  plugins: [],
} satisfies Config;
