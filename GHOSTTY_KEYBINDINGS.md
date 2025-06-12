# Ghostty Terminal Keybindings for Neovim

This document explains how to configure Ghostty terminal to work seamlessly with Neovim on macOS, enabling native Command key shortcuts.

## Ghostty Configuration

Add these keybindings to your Ghostty configuration file (`~/.config/ghostty/config` or via the GUI settings):

```toml
# Command+S to save (sends Ctrl+S to Neovim)
keybind = cmd+s:text:\x13

# Optional: Additional macOS-style keybindings
# Command+Q to quit all (sends :qa<CR> to Neovim)
keybind = cmd+q:text:\x1b:qa\r

# Command+W to close buffer (sends :bd<CR> to Neovim)
keybind = cmd+w:text:\x1b:bd\r

# Command+F for fuzzy find (sends <leader>ff)
# Note: Assumes space as leader key
keybind = cmd+f:text:\x1b ff

# Command+P for command palette (telescope)
keybind = cmd+p:text:\x1b ff
```

## How It Works

1. **Command+S**: Ghostty captures `cmd+s` and sends `Ctrl+S` (hex `\x13`) to Neovim
2. Neovim receives `Ctrl+S` and executes the save command (`:w`)
3. The keybinding works in all modes (normal, insert, visual) and stays in the current mode

## Disable Terminal Flow Control

To ensure Ctrl+S doesn't freeze the terminal, add this to your shell configuration:

### For Zsh (`~/.zshrc`):
```bash
# Disable XON/XOFF flow control
stty -ixon
```

### For Bash (`~/.bashrc`):
```bash
# Disable XON/XOFF flow control
stty -ixon
```

## Verifying Your Setup

1. Open Neovim in Ghostty
2. Press `Cmd+S` - the file should save
3. In insert mode, press `Cmd+S` - you should remain in insert mode after saving

## Additional Notes

- Ghostty uses `cmd` or `super` to refer to the Command key on macOS
- The `keybind` format is: `keybind = modifier+key:action:data`
- For global keybindings (work across all Ghostty windows), prefix with `global:`
- Hex codes: `\x13` = Ctrl+S, `\x1b` = Escape

## Troubleshooting

If Command+S doesn't work:
1. Check that flow control is disabled: run `stty -a | grep ixon` (should show `-ixon`)
2. Verify Ghostty config is loaded: restart Ghostty after configuration changes
3. Test with `:verbose map <C-s>` in Neovim to see if the mapping exists

## References

- [Ghostty Documentation](https://github.com/mitchellh/ghostty)
- [Neovim Key Notation](https://neovim.io/doc/user/intro.html#key-notation)