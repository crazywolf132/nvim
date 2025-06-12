# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modern, feature-rich Neovim configuration designed for Rust, Go, and Web development on macOS with Ghostty terminal. The configuration follows a modular structure based on lazy.nvim for plugin management, prioritizing performance while providing a comprehensive development environment.

## Key Commands

### Development Workflow
- `:Mason` - Open Mason package manager to install/manage LSP servers, formatters, linters
- `:Lazy` - Open Lazy plugin manager for plugin management
- `:checkhealth` - Run Neovim health checks to diagnose issues

### Essential Keybindings
- `<Space>` - Leader key
- `<C-s>` / `<D-s>` - Save file (with formatting)
- `<C-S-s>` / `<D-S-s>` - Save without formatting
- `<Space><Space>` - Quick find files
- `<Space>gg` - Git status (Fugitive)
- `<Space>gl` - LazyGit
- `<C-\>` - Toggle terminal
- `<Space>a` - Toggle code structure (Aerial)
- `-` - Open parent directory (Oil)
- `<Space>e` - File explorer (floating)

### Diagnostic and Debugging
- `:LspInfo` - Show active LSP clients and their status
- `:Lazy profile` - Check plugin load times for performance debugging
- `:Telescope diagnostics` - View all project diagnostics in fuzzy finder
- `:Trouble` - Enhanced diagnostics UI

### Plugin Updates
- `:Lazy update` - Update plugins (respects lockfile)
- `:Lazy sync` - Sync plugin state with configuration
- `:TSUpdate` - Update Treesitter parsers

## Architecture

### Core Structure
- `init.lua` - Main entry point, bootstraps lazy.nvim and loads configuration modules
- `lua/config/` - Core Neovim settings (options, keymaps, autocommands)
- `lua/plugins/` - Modular plugin specifications organized by function

### Plugin Organization
- `plugins/init.lua` - Plugin manager setup and imports
- `plugins/lsp.lua` - LSP servers, completion, formatting, testing, and diagnostics
- `plugins/ui.lua` - UI enhancements (colorschemes, statusline, which-key, comments, dashboard)
- `plugins/devtools.lua` - Development tools (treesitter, git, telescope, terminal, file management)
- `plugins/sage.lua` - Sage SCM integration

### Key Plugin Ecosystem
- **Plugin Manager**: lazy.nvim with aggressive lazy-loading for performance
- **LSP**: nvim-lspconfig + Mason for automatic LSP server management
- **Completion**: nvim-cmp with multiple sources (LSP, snippets, buffer, path)
- **Formatting**: none-ls.nvim (null-ls fork) for external formatters/linters
- **Syntax**: Treesitter for accurate highlighting and text objects
- **Navigation**: Telescope + Harpoon for fuzzy finding and quick file access
- **Git**: Fugitive + Gitsigns + LazyGit + Diffview for comprehensive Git workflow
- **File Management**: Oil.nvim replaces netrw for directory editing
- **Testing**: Neotest with language-specific adapters (Go, Rust, Jest)
- **Diagnostics**: Trouble.nvim for enhanced LSP diagnostics and references

## Language-Specific Features

### Rust Development
- **rustaceanvim** for advanced rust-analyzer integration with enhanced features
- Clippy integration with checkOnSave
- Cargo.toml enhancement via crates.nvim for dependency management
- Rust-specific keybindings for runnables, debuggables, and macro expansion
- Cargo commands: `<leader>rc` (check), `<leader>rt` (test), `<leader>rr` (run)

### Go Development  
- **gopls** with gofumpt formatting and import organization
- Static analysis and unused parameter detection enabled
- Go-specific commands: `<leader>gt` (test), `<leader>gr` (run)
- Auto-formatting with gofumpt and goimports

### Web Development (TypeScript/JavaScript)
- **typescript-tools.nvim** for enhanced TypeScript support (performance optimized)
- Automatic fallback to ts_ls when typescript-tools not available
- ESLint integration with auto-fix on save
- Prettier formatting via none-ls
- Package.json support with package-info.nvim for version management
- Auto-tag closing for HTML/JSX/TSX with nvim-ts-autotag
- TypeScript keybindings: `<leader>tsi` (organize imports), `<leader>tsr` (remove unused)

### Additional Languages
- **HTML/CSS**: Language servers with Emmet support, TailwindCSS integration
- **JSON**: Schema validation support
- **Markdown**: Marksman LSP, live preview options (browser + terminal with Glow)
- **Lua**: Optimized for Neovim configuration development

## macOS/Ghostty Integration

### Command Key Support
- Full macOS Command key shortcuts via terminal passthrough
- `Cmd+S` and `Cmd+Shift+S` for save operations
- Optimized for Ghostty terminal with true color support

### Performance Optimizations
- Aggressive lazy-loading with event-based plugin activation
- Disabled unused Neovim providers (Python, Ruby, Node, Perl)
- Persistent undo with dedicated cache directory
- Auto-save on focus lost and buffer changes
- Optimized LSP settings with separated diagnostic servers

## Advanced Features

### Navigation and Workflow
- **Harpoon v2** for lightning-fast file switching (`<leader>ha` to add, `<leader>1-5` for quick access)
- **Oil.nvim** for directory editing with vim-like operations
- **Aerial.nvim** for code structure navigation
- **Alpha dashboard** with startup screen and plugin load times
- **Session management** with persistence.nvim

### UI Enhancements
- **Multiple colorschemes**: Oxocarbon (default), TokyoNight, OldWorld
- **True Zen modes** for distraction-free writing and focus
- **Multi-cursor support** with vim-visual-multi
- **Which-key** for command discoverability
- **Global statusline** with diagnostic integration

### Development Tools
- **Todo Comments** with highlighting and telescope integration
- **Refactoring tools** for extract function/variable operations
- **Git integration**: Multiple tools for different workflows
- **EditorConfig** support for project-specific settings
- **Auto-pairs** and **surround** operations

## Configuration Patterns

### Adding New Languages
1. Add LSP server to `mason-lspconfig` ensure_installed list in `lsp.lua`
2. Configure server using the common on_attach function
3. Add formatter/linter to none-ls sources if needed
4. Add Treesitter parser to ensure_installed list in `devtools.lua`
5. Create language-specific autocommands in `autocmds.lua` if needed

### Modifying Keymaps
- Global keymaps in `lua/config/keymaps.lua`
- LSP keymaps in the on_attach function in `lua/plugins/lsp.lua`
- Plugin-specific keymaps in respective plugin configurations
- Update which-key labels in `lua/plugins/ui.lua` for discoverability

### Plugin Management
- All plugins use aggressive lazy-loading via events, commands, filetypes, or keys
- Plugin lockfile (`lazy-lock.json`) ensures reproducible installs
- Performance-first approach with conditional loading
- Modular organization prevents configuration conflicts

## Development Best Practices

### Code Formatting
- Format-on-save enabled for all supported languages
- Save without formatting available (`<C-S-s>`) for special cases
- LSP formatting prioritized, with none-ls for external tools
- Language-specific formatting rules (Go uses tabs, others use spaces)

### Git Workflow
- **Gitsigns** for inline change indicators and hunk operations
- **Fugitive** for comprehensive Git commands within Neovim
- **LazyGit** for visual Git interface
- **Diffview** for side-by-side diff viewing and file history

### Testing
- **Neotest** provides unified testing interface
- Language-specific adapters: neotest-go, neotest-rust, neotest-jest
- Test keybindings: `<leader>tt` (nearest), `<leader>tf` (file), `<leader>ta` (all)

### Performance Considerations
- Configuration optimized for large codebases (5000+ lines)
- Treesitter auto-disables for very large files
- TypeScript memory limits and separated diagnostic servers
- Diagnostic updates optimized with updatetime=250ms
- Auto-save and reload functionality for smooth workflow

## Troubleshooting Common Issues

### LSP Problems
- Run `:checkhealth` to verify dependencies
- Use `:LspInfo` to check server status
- Check `:Mason` for tool installation status
- Ensure required system tools (ripgrep, fd, node, rust, go) are installed

### Plugin Issues  
- Check `:Lazy` for plugin status and errors
- Use `:Lazy profile` to identify performance bottlenecks
- Verify lazy-lock.json is committed for reproducible builds
- Update plugins carefully and test after updates

### Performance Issues
- Use `:Lazy profile` to identify slow-loading plugins
- Check TypeScript memory usage if working with large TS projects
- Consider disabling features for very large files (>5000 lines)
- Ensure external tools (ripgrep, fd) are installed for optimal performance

### TypeScript Specific
- typescript-tools.nvim loads conditionally based on project files
- Fallback to ts_ls when typescript-tools not loaded
- Memory limits configured for large TypeScript projects
- Separated diagnostic server for better performance