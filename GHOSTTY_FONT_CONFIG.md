# Ghostty Font Configuration for DankMono with Ligatures

To use DankMono Nerd Font with ligatures in Ghostty terminal, add these settings to your Ghostty config file (`~/.config/ghostty/config`):

```
# Font settings
font-family = DankMono Nerd Font
font-size = 14

# Enable ligatures
font-feature = +liga
font-feature = +calt

# Optional: adjust line height if needed
# line-height = 1.2

# Optional: for italic variant
# font-family-italic = DankMono Nerd Font Italic

# Optional: for bold variant
# font-family-bold = DankMono Nerd Font Bold
```

## Common Ligatures in DankMono

DankMono includes programming ligatures for common character combinations:
- `=>` (arrow function)
- `->` (arrow)
- `==` (equality)
- `===` (strict equality)
- `!=` (not equal)
- `!==` (strict not equal)
- `>=` (greater than or equal)
- `<=` (less than or equal)
- `::` (scope resolution)
- `...` (spread operator)
- `//` (comment)
- `/*` and `*/` (block comments)
- `&&` (logical AND)
- `||` (logical OR)
- `??` (nullish coalescing)

## Verifying Installation

1. Check if the font is installed:
   ```bash
   fc-list | grep -i "dankmon"
   ```

2. If not installed, install via Homebrew:
   ```bash
   brew tap homebrew/cask-fonts
   brew install --cask font-dank-mono
   ```

3. Restart Ghostty after changing font settings

## Note

Since you're using terminal Neovim (not a GUI version), the font rendering is entirely controlled by your terminal emulator (Ghostty). The Neovim font settings we added only apply if you ever use a GUI version like Neovide.