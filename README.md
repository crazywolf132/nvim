# Neovim Configuration

A modern, minimal yet powerful Neovim configuration for Rust, Go, and Web development on macOS with Ghostty terminal.

## Features

- **LSP Support**: Full language server support for Rust, Go, TypeScript/JavaScript, HTML, CSS, and more
- **Auto-completion**: Smart code completion with nvim-cmp and snippets
- **Syntax Highlighting**: Treesitter-based highlighting with support for many languages
- **Git Integration**: Fugitive for Git commands, Gitsigns for inline changes, Diffview for reviewing diffs
- **File Navigation**: Telescope fuzzy finder with ripgrep integration
- **Terminal**: Integrated terminal with toggleterm
- **Markdown**: Live preview in browser or terminal (Glow)
- **Format on Save**: Automatic code formatting using LSP and null-ls
- **macOS Integration**: Command+S save support via Ghostty

## Requirements

- Neovim 0.11.1 or later
- Git
- Node.js (for many LSP servers and tools)
- Rust toolchain (for Rust development)
- Go (for Go development)
- ripgrep (`brew install ripgrep`)
- fd (`brew install fd`)
- A Nerd Font (optional but recommended)

## Installation

1. Clone this configuration:
   ```bash
   git clone <your-repo> ~/.config/nvim
   ```

2. Launch Neovim:
   ```bash
   nvim
   ```

3. Plugins will automatically install on first launch

4. Install LSP servers and tools:
   ```vim
   :Mason
   ```
   
   Then install the servers you need (rust-analyzer, gopls, typescript-language-server, etc.)

## Key Mappings

Leader key: `<Space>`

### Essential
- `<C-s>` / `<Cmd-s>`: Save file
- `<leader>qq`: Quit all
- `<leader>l`: Open Lazy plugin manager

### File Navigation
- `<leader>ff`: Find files
- `<leader>fg`: Live grep
- `<leader>fb`: List buffers
- `<leader>fh`: Search help

### LSP
- `gd`: Go to definition
- `gr`: Find references
- `K`: Hover documentation
- `<leader>rn`: Rename symbol
- `<leader>ca`: Code action
- `[d` / `]d`: Previous/next diagnostic

### Git
- `<leader>gg`: Git status (Fugitive)
- `<leader>hs`: Stage hunk
- `<leader>hr`: Reset hunk
- `<leader>hb`: Blame line
- `[c` / `]c`: Previous/next git hunk

### Window Management
- `<C-h/j/k/l>`: Navigate windows
- `<leader>w-`: Split horizontally
- `<leader>w|`: Split vertically
- `<leader>wd`: Close window

### Terminal
- `<C-\>`: Toggle floating terminal

### Markdown
- `<leader>mp`: Markdown preview (browser)
- `<leader>mg`: Markdown preview (Glow terminal)

### Utilities
- `<leader>y`: Yank to system clipboard
- `<leader>p`: Paste from system clipboard
- `<leader>sr`: Search and replace
- `<leader>uw`: Toggle word wrap
- `<leader>us`: Toggle spell check

## Customization

### Adding Plugins
Edit `lua/plugins/*.lua` files to add new plugins. The configuration is modular:
- `lua/plugins/lsp.lua`: LSP and completion plugins
- `lua/plugins/ui.lua`: UI enhancements
- `lua/plugins/devtools.lua`: Development tools

### Keymaps
Edit `lua/config/keymaps.lua` to add or modify key mappings.

### Options
Edit `lua/config/options.lua` to change Neovim options.

### Autocommands
Edit `lua/config/autocmds.lua` to add automatic commands.

## Ghostty Integration

See `GHOSTTY_KEYBINDINGS.md` for setting up macOS Command key shortcuts.

## Troubleshooting

### Health Check
Run `:checkhealth` to diagnose issues.

### Plugin Issues
- `:Lazy` to see plugin status
- `:Lazy update` to update plugins
- `:Lazy sync` to sync plugin state

### LSP Issues
- `:LspInfo` to see active LSP clients
- `:Mason` to manage LSP servers

### Performance
- `:Lazy profile` to check plugin load times

## Optional Enhancements

### For Advanced Rust Development
Uncomment rustaceanvim in `lua/plugins/lsp.lua` for enhanced Rust features.

### For Advanced TypeScript Development
Uncomment typescript.nvim in `lua/plugins/lsp.lua` for features like file rename on symbol rename.

## License

This configuration is provided as-is for personal use.