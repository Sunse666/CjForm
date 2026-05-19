# Theme System

CJForm has built-in Dark / Light themes with runtime switching.

## Switching Themes

```cj
// Set to dark theme
Theme.setCurrent(Theme.dark())

// Set to light theme
Theme.setCurrent(Theme.light())

// Toggle between them
Theme.toggle()
```

After switching themes, reapply the window background:

```cj
Theme.toggle()
win.setBackgroundColor(Theme.colors().bgSecondary)
```

## Getting Theme Colors

```cj
let c = Theme.colors()
c.bgPrimary     // Primary background
c.bgSecondary   // Secondary background
c.textPrimary   // Primary text color
c.accent        // Accent color
```

## Complete Color Reference

### Background

| Property | Description |
|------|------|
| `bgPrimary` | Primary background |
| `bgSecondary` | Secondary background |
| `bgTertiary` | Tertiary background |

### Text

| Property | Description |
|------|------|
| `textPrimary` | Primary text |
| `textSecondary` | Secondary text |
| `textTertiary` | Tertiary text |

### Accent

| Property | Description |
|------|------|
| `accent` | Accent color |
| `accentHover` | Accent hover |
| `accentPressed` | Accent pressed |

### Border

| Property | Description |
|------|------|
| `border` | Border color |
| `borderFocused` | Focused border |

### Semantic

| Property | Description |
|------|------|
| `danger` | Danger/error |
| `success` | Success |
| `warning` | Warning |
| `shadow` | Shadow color |

### Button

| Property | Description |
|------|------|
| `buttonBg` | Button background |
| `buttonHover` | Button hover |
| `buttonPressed` | Button pressed |
| `buttonText` | Button text |

### Input

| Property | Description |
|------|------|
| `inputBg` | Input background |
| `inputBorder` | Input border |
| `inputPlaceholder` | Placeholder text |

### Slider

| Property | Description |
|------|------|
| `sliderTrack` | Track color |
| `sliderFill` | Fill color |
| `sliderThumb` | Thumb color |

### Progress Bar

| Property | Description |
|------|------|
| `progressTrack` | Track color |
| `progressFill` | Fill color |

### Toggle Switch

| Property | Description |
|------|------|
| `toggleTrack` | Track (off) |
| `toggleTrackOn` | Track (on) |
| `toggleThumb` | Thumb color |

### Separator

| Property | Description |
|------|------|
| `separator` | Separator color |

### Scrollbar

| Property | Description |
|------|------|
| `scrollbarTrack` | Track color |
| `scrollbarThumb` | Thumb color |
| `scrollbarThumbHover` | Thumb hover |

### Tab

| Property | Description |
|------|------|
| `tabActiveBg` | Active tab background |
| `tabInactiveBg` | Inactive tab background |
| `tabActiveText` | Active tab text |
| `tabInactiveText` | Inactive tab text |

### Table

| Property | Description |
|------|------|
| `tableHeaderBg` | Header background |
| `tableHeaderText` | Header text |
| `tableGridLine` | Grid lines |
| `tableSelectedBg` | Selected row |
| `tableRowEven` | Even row |
| `tableRowOdd` | Odd row |

### Popup

| Property | Description |
|------|------|
| `popupBg` | Popup background |
| `popupBorder` | Popup border |
| `popupItemHover` | Item hover |
| `popupItemText` | Item text |
| `popupItemTextSecondary` | Item secondary text |

## Style Structs & Themes

Each widget's Style struct has an `isThemeBased` field. When `true`, `fromTheme()` uses the current theme colors:

```cj
// Use theme colors (auto-adapt on theme switch)
ButtonStyle.fromTheme()

// Use custom colors (no theme adaptation)
ButtonStyle.custom(bg, text, 4.0, 1.0, border)
```

## Custom Colors

All colors use the `Color` struct:

```cj
Color.rgb(255, 100, 50)       // RGB
Color.rgba(255, 100, 50, 200) // RGBA (with alpha)

// Predefined colors
Color.WHITE
Color.BLACK
Color.RED
Color.GREEN
Color.BLUE
Color.LIGHT_GRAY
Color.GRAY
Color.DARK_GRAY
```
