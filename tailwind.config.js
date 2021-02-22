const colors = require('tailwindcss/colors');

module.exports = {
  purge: ["./templates/**/*.html", "./theme/**/*.html"],
  theme: {
    colors: {
      transparent: 'transparent',
      current: 'currentColor',
      gray: colors.coolGray,
      black: colors.black,
      green: colors.emerald,
      teal: colors.teal
    }
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography')
  ],
};
