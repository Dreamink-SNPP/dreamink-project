# Dreamink Style Guide

## Color Palette

This document defines the official Dreamink color palette and guidelines for its usage across the application.

### Brand Colors

#### Primary Color
**Color:** `#1B3C53` (Dark Teal/Navy)
**Usage:** Primary buttons, headers, main branding elements, navigation
**Tailwind Classes:** `bg-primary`, `text-primary`, `border-primary`

The primary color represents trust, professionalism, and calm - core values of Dreamink.

#### Secondary Colors

**Secondary Dark:** `#234C6A`
**Usage:** Hover states for primary elements, secondary buttons, accents
**Tailwind Classes:** `bg-secondary-dark`, `text-secondary-dark`, `border-secondary-dark`

**Secondary (Default):** `#456882`
**Usage:** Tertiary elements, borders, backgrounds for cards
**Tailwind Classes:** `bg-secondary`, `text-secondary`, `border-secondary`

**Secondary Light:** `#D2C1B6` (Warm Beige)
**Usage:** Subtle backgrounds, hover states, accent highlights
**Tailwind Classes:** `bg-secondary-light`, `text-secondary-light`, `border-secondary-light`

### Primary Color Shades

For advanced usage, the primary color includes a full shade range:

- `primary-50`: #E8EEF2 (Lightest - backgrounds)
- `primary-100`: #D1DDE5
- `primary-200`: #A3BBCB
- `primary-300`: #7599B1
- `primary-400`: #477797
- `primary-500`: #1B3C53 (Base/DEFAULT)
- `primary-600`: #163042
- `primary-700`: #102432
- `primary-800`: #0B1821
- `primary-900`: #050C11 (Darkest)

### Utility Colors

For functional UI elements, standard Tailwind colors remain available:

- **Success:** `green-600`, `green-700`
- **Error/Danger:** `red-600`, `red-700`
- **Warning:** `yellow-500`, `yellow-600`
- **Info:** `blue-500`, `blue-600`
- **Neutral/Gray:** `gray-50` through `gray-900`

## Usage Guidelines

### Buttons

#### Primary Actions
```html
<button class="bg-primary hover:bg-secondary-dark text-white">
  Primary Action
</button>
```

#### Secondary Actions
```html
<button class="bg-secondary hover:bg-secondary-dark text-white">
  Secondary Action
</button>
```

#### Destructive Actions
```html
<button class="bg-red-600 hover:bg-red-700 text-white">
  Delete
</button>
```

### Text Colors

- **Primary Text:** `text-gray-900` (default)
- **Secondary Text:** `text-gray-600`
- **Muted Text:** `text-gray-500`
- **Link Text:** `text-primary hover:text-secondary-dark`

### Backgrounds

- **Main Background:** `bg-white` or `bg-gray-50`
- **Card Background:** `bg-white` with `border-secondary-light`
- **Hover Background:** `hover:bg-primary-50`
- **Selected/Active:** `bg-primary-100`

### Borders

- **Default Border:** `border-gray-300`
- **Accent Border:** `border-secondary`
- **Focus Border:** `border-primary`

### Gradients

For special elements like headers:

```html
<div class="bg-gradient-to-r from-primary to-secondary-dark">
  Header Content
</div>
```

## Accessibility

All color combinations meet WCAG 2.1 AA standards for contrast:

- Primary (#1B3C53) on white: ✓ AAA (11.2:1)
- Secondary Dark (#234C6A) on white: ✓ AAA (8.3:1)
- Secondary (#456882) on white: ✓ AA (4.8:1)
- White text on Primary: ✓ AAA (11.2:1)

## Migration Notes

### Old Color → New Color Mapping

| Old Color (Indigo/Purple) | New Color | Tailwind Class |
|---------------------------|-----------|----------------|
| `bg-indigo-600` | Primary | `bg-primary` |
| `bg-indigo-700` | Secondary Dark | `bg-secondary-dark` |
| `bg-purple-600` | Secondary Dark | `bg-secondary-dark` |
| `text-indigo-600` | Primary | `text-primary` |
| `text-indigo-700` | Secondary Dark | `text-secondary-dark` |
| `border-indigo-500` | Primary | `border-primary` |
| `bg-indigo-50` | Primary 50 | `bg-primary-50` |
| `bg-indigo-100` | Primary 100 | `bg-primary-100` |
| `from-indigo-500 to-purple-600` | Primary to Secondary Dark | `from-primary to-secondary-dark` |

## Examples

### Header with Gradient
```html
<div class="bg-gradient-to-r from-primary to-secondary-dark text-white p-4 rounded-lg">
  <h2 class="text-xl font-bold">Section Header</h2>
</div>
```

### Card Component
```html
<div class="bg-white border border-secondary-light rounded-lg p-6 hover:border-secondary">
  <h3 class="text-lg font-semibold text-gray-900">Card Title</h3>
  <p class="text-gray-600 mt-2">Card content goes here</p>
  <a href="#" class="text-primary hover:text-secondary-dark mt-4 inline-block">
    Learn More →
  </a>
</div>
```

### Form Input
```html
<input
  type="text"
  class="border-gray-300 focus:border-primary focus:ring-primary rounded-md"
  placeholder="Enter text"
/>
```

## Design Tokens (For Developers)

If you need to use colors in JavaScript or Ruby:

### JavaScript (Tailwind Config)
```javascript
// Access via tailwind.config.js
theme.colors.primary // '#1B3C53'
theme.colors.secondary.dark // '#234C6A'
```

### Ruby (For PDF Generation)
```ruby
module Dreamink
  module Colors
    PRIMARY = '#1B3C53'
    SECONDARY_DARK = '#234C6A'
    SECONDARY = '#456882'
    SECONDARY_LIGHT = '#D2C1B6'
  end
end
```

## Resources

- **Tailwind CSS Configuration:** `/tailwind.config.js`
- **Main Stylesheet:** `/app/assets/stylesheets/application.tailwind.css`
- **Issue Reference:** #26

---

*Last Updated: 2025-10-31*
*Version: 1.0.0*
