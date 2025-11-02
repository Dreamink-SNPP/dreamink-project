// Prettier configuration for Tailwind CSS class sorting
// See: https://github.com/tailwindlabs/prettier-plugin-tailwindcss

module.exports = {
  // Enable Tailwind CSS plugin for automatic class sorting
  plugins: ['prettier-plugin-tailwindcss'],

  // Prettier formatting options optimized for Rails ERB templates
  printWidth: 120,
  tabWidth: 2,
  useTabs: false,
  semi: true,
  singleQuote: false,
  quoteProps: 'as-needed',
  trailingComma: 'es5',
  bracketSpacing: true,
  bracketSameLine: false,
  arrowParens: 'always',

  // ERB-specific overrides
  overrides: [
    {
      files: '*.html.erb',
      options: {
        parser: 'html',
        // Preserve ERB tags and Ruby code
        htmlWhitespaceSensitivity: 'ignore',
      },
    },
  ],
};
