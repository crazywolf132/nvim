Neovim Configuration Plan for Rust, Go, and Web Development on macOS (Ghostty Terminal)

Overview and Base Configuration Decision

For a modern, intuitive, minimal yet powerful Neovim setup, we will build on a lightweight base rather than a heavy distribution. Kickstart.nvim is an ideal starting point – it’s a minimal Lua config with best practices and extensive commenting, making it easy to customize and maintain ￼. In contrast, full-fledged distros like AstroNvim, while feature-rich and stable, include many plugins by default (approaching an “IDE-like” experience) and change frequently ￼ ￼. As a power user who wants to “own” the config and keep it lean, we will use Kickstart.nvim’s philosophy (simple, documented config) as our foundation, gradually extending it with only necessary, well-maintained plugins.

This approach ensures we have full control and understanding of the setup, avoiding the “vendor lock-in” or bloat of large distributions ￼ ￼. We will organize the configuration in a modular way for clarity and long-term maintainability. The latest Neovim 0.11+ features (like new LSP configuration APIs and global UI settings) will be utilized where beneficial, but we’ll rely on battle-tested community plugins for most functionality to provide a robust experience.

File Structure and Installation Setup

We will structure the Neovim config as follows (inside ~/.config/nvim on macOS):

￼ ￼

~/.config/nvim/  
├── init.lua               -- Main entry point (loads plugins and config)  
└── lua/                   -- Lua configuration directory  
    ├── config/            -- Core settings and keymaps  
    │   ├── options.lua    -- Vim options/settings (ui, indents, etc.)  
    │   ├── keymaps.lua    -- Global key mappings (incl. macOS shortcuts)  
    │   └── autocmds.lua   -- Autocommands (if any, e.g. format on save)  
    └── plugins/           -- Plugin specifications and configuration  
        ├── init.lua       -- Plugin manager setup (lazy.nvim)  
        ├── lsp.lua        -- LSP and completion plugins setup  
        ├── ui.lua         -- UI plugins (statusline, colorscheme, etc.)  
        ├── devtools.lua   -- Dev-related plugins (treesitter, git, terminal, etc.)  
        └── … (optional additional plugin config files as needed) 

This modular layout keeps configuration logical and manageable, separating concerns (keymaps vs plugins vs settings) ￼.

Installation instructions:
	1.	Install Neovim 0.11.1 (or latest stable) for macOS. Using Homebrew is recommended (e.g. brew install neovim).
	2.	Prerequisites: Ensure required system dependencies are present:
	•	Developer tools: git, gcc/Xcode Command Line Tools, make, unzip (for building some plugins) ￼.
	•	Fuzzy search tools: ripgrep (rg) and fd (fd-find), which telescope will use for blazing-fast search ￼.
	•	Language runtimes: Rust (with rustup and cargo), Go, Node.js (for JavaScript/TypeScript). These provide LSP servers or formatter tools (e.g. rust-analyzer, gopls, tsserver, eslint, prettier) ￼.
	•	Nerd Font (optional): Install a Nerd Font (e.g. Hack Nerd Font or JetBrainsMono Nerd Font) to ensure special icons/devicons render properly ￼. (Note: Ghostty can render glyphs with font fallbacks, so a patched font is optional, but recommended for consistency ￼ ￼.)
	3.	Bootstrap the config: Clone the Git repository containing the above config structure (or create the files manually). For example, if using Kickstart.nvim as a base, fork it and clone into ~/.config/nvim ￼ ￼. Otherwise, create an init.lua and the described directories/files.
	4.	Install plugin manager (lazy.nvim): We’ll use lazy.nvim for managing plugins, as it supports lazy-loading and is the modern standard. The init.lua will contain bootstrap code to install lazy.nvim if not already present, then load our plugin specs. For example:

-- init.lua (excerpt)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")   -- load all plugin specs from lua/plugins directory


	5.	First run: Launch nvim. Lazy.nvim will automatically download and install the specified plugins on first start. Use :Lazy to check plugin status ￼. Restart Neovim after installation for all features to take effect.

By tracking the lazy-lock.json (plugin lockfile) in version control, we can ensure reproducible and stable plugin versions ￼. This prevents updates from unexpectedly breaking the setup – updates can be done intentionally and carefully.

Now, we detail the chosen plugins and configurations by category, with rationale for each choice.

Plugins and Configuration Details

1. LSP Configuration and Autocompletion

Neovim 0.11 has built-in LSP client improvements, but we’ll leverage the well-established nvim-lspconfig plugin (which provides configurations for many servers) for simplicity and broad community support. We combine this with mason.nvim to easily install/manage language servers and tools ￼, and nvim-cmp for autocompletion UI ￼.
	•	Plugin: williamboman/mason.nvim – Mason provides a convenient package manager UI for LSP servers, linters, and formatters ￼. We’ll use Mason to install:
	•	Rust: rust-analyzer LSP.
	•	Go: gopls LSP.
	•	Web: tsserver (TypeScript/JavaScript LSP), html and cssls (HTML/CSS LSPs), plus any needed linters/formatters.
	•	Markdown: (optional) marksman LSP for markdown, and markdownlint for linting, can be installed via Mason.
Mason will ensure these servers are present and can auto-update them. We’ll configure Mason alongside williamboman/mason-lspconfig.nvim to link Mason and lspconfig easily.
	•	Plugin: neovim/nvim-lspconfig – Enables quick LSP server setup. We will configure language servers with sensible defaults:
	•	Attach completion (nvim-cmp) and keybindings on LSP attach.
	•	Enable LSP-based features: go-to-definition, hover docs, rename, code actions, diagnostics, etc.
	•	Use Neovim 0.11’s new global setting for floating window border: e.g. vim.o.winborder = 'rounded' to get nice rounded borders on hover and diagnostic popups ￼.
	•	Rust-specific: We’ll let rust-analyzer provide inlay type hints (Neovim 0.11 supports inlay hints natively). We can enable them via vim.lsp.inlay_hint(0, true) on attach, so you’ll see inline type info for Rust.
	•	Go-specific: gopls will be configured to format on save (using gofumpt) and to organize imports on save via LSP settings.
	•	TS/JS-specific: tsserver will be configured. Optionally, we might include jose-elias-alvarez/typescript.nvim for extra TS utilities (like rename file on rename symbol, etc.), but we’ll keep it minimal unless needed.
Justification: With LSP, Neovim acts like a full IDE for our languages ￼, providing “code completion, refactoring, code analysis, go-to definition, code actions, references, hover docs, and formatting” ￼. This covers Rust (via rust-analyzer), Go, and web languages in a unified way.
	•	Plugin: hrsh7th/nvim-cmp – A completion engine that shows suggestion pop-ups as you type. We’ll pair it with:
	•	hrsh7th/cmp-nvim-lsp (LSP source for cmp),
	•	hrsh7th/cmp-buffer (buffer words completion),
	•	hrsh7th/cmp-path (filesystem paths),
	•	saadparwaiz1/cmp_luasnip (snippets source).
This gives a smooth autocomplete experience with LSP suggestions, buffer words, etc., ranked appropriately. It’s essential for productivity – “living without autocomplete is painful” ￼, so nvim-cmp is a must-have modern plugin.
	•	Plugin: L3MON4D3/LuaSnip – Snippet engine for code snippets, integrated with nvim-cmp for suggestions ￼. We will include rafamadriz/friendly-snippets, a community collection of snippets for many languages (Rust, Go, JS, etc.), to kickstart the snippet library. This allows expanding common boilerplate quickly (e.g., fn -> expands to Rust function template).
	•	Plugin: onsails/lspkind.nvim – Adds VSCode-like pictograms to completion menu entries for better UX (e.g., showing 🅰 for Text, ƒ for Function), making the autocomplete menu more intuitive.
	•	Rust enhancements: For advanced Rust developers, we note that the once-popular rust-tools.nvim has been archived in favor of new solutions ￼. We will not use rust-tools (to keep setup minimal and stable), but instead:
	•	Rely on built-in LSP and Neovim 0.11 features for most things (inlay hints, etc.).
	•	Optionally suggest mrcjkb/rustaceanvim in documentation – a newer plugin that auto-configures rust-analyzer with extra features (like enhanced hover actions, standalone cargo command integration) without needing lspconfig ￼ ￼. It’s targeted at heavy Rust users wanting more than the basics, but it’s purely optional. Our base setup will function well with just rust-analyzer.
	•	We will include saecki/crates.nvim, a lightweight plugin that enhances Cargo.toml files – it provides version completion and updates for Rust crates. It’s well-maintained and will show you the latest version of dependencies and allow updating them easily, fitting our “power user” convenience.
	•	Go enhancements (optional): Go works well with just gopls. If needed, one could add ray-x/go.nvim which provides extra Go-specific commands (e.g., to quickly run tests or coverage). Since no testing/debug is needed in our scope and to remain minimal, we skip it. Our config will handle formatting and import organizing via gopls and null-ls (see below).
	•	Code Formatting and Linting: We ensure code is auto-formatted on save and linted:
	•	Use LSP’s formatting where available (rust-analyzer can invoke rustfmt, gopls has formatting, tsserver can format basic, though we prefer Prettier for TS/JS).
	•	Plugin: jose-elias-alvarez/null-ls.nvim – This plugin acts as a bridge to hook external formatters/linters into Neovim as pseudo-LSP sources. We will use null-ls to integrate:
	•	Prettier for formatting JavaScript/TypeScript, HTML, CSS, Markdown.
	•	ESLint for linting JS/TS.
	•	golines or gofmt for advanced Go formatting (if gopls formatting is insufficient).
	•	markdownlint for Markdown linting.
	•	Possibly shellcheck/shfmt for shell scripts, etc., as needed.
Mason can install many of these (via mason-null-ls.nvim to auto link them). The result: on saving a file, the appropriate formatter will run (via LSP or null-ls) and fix code style. This keeps the codebase tidy effortlessly. We will set up autocmds to format on save for relevant filetypes (or use the LSP on_attach to bind vim.lsp.buf.format() on BufWritePre).
For linting, null-ls will surface issues (e.g., ESLint warnings) as virtual text or in the location list, enhancing feedback as you code.

Configuration Snippet (LSP & CMP):

In lua/plugins/lsp.lua:

return {
  -- Mason to install LSPs/linters/formatters
  { 'williamboman/mason.nvim', config = true },  -- uses default config, installs :Mason command
  { 'williamboman/mason-lspconfig.nvim', after = 'mason.nvim', config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'rust_analyzer', 'gopls', 'tsserver', 'html', 'cssls', 'marksman' },
        automatic_installation = true,
      })
    end
  },
  -- LSPconfig
  { 'neovim/nvim-lspconfig', after = 'mason-lspconfig.nvim', config = function()
      local lsp = require('lspconfig')
      -- Common on_attach for all LSPs
      local on_attach = function(client, bufnr)
        -- Keybindings for LSP (only active in LSP buffers)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', 'Go to Definition')
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', 'Hover Documentation')
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', 'Find References')
        bufmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename Symbol')
        bufmap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action')
        -- etc...
        -- Enable inlay hints for Neovim 0.11+
        if vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(bufnr, true) end
      end
      -- LSP server setups
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Rust
      lsp.rust_analyzer.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = { 
          ['rust-analyzer'] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" }  -- run clippy for lint on save
          }
        }
      }
      -- Go
      lsp.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,  -- use gofumpt stricter format
            analyses = { unusedparams = true },
            staticcheck = true,
          }
        }
      }
      -- TypeScript/JavaScript
      lsp.tsserver.setup { on_attach = on_attach, capabilities = capabilities }
      -- HTML/CSS
      lsp.html.setup   { on_attach = on_attach, capabilities = capabilities }
      lsp.cssls.setup  { on_attach = on_attach, capabilities = capabilities }
      -- Markdown (marksman)
      lsp.marksman.setup { on_attach = on_attach, capabilities = capabilities }
      -- ... additional servers if needed
      -- Global floating window border
      vim.o.winborder = 'rounded'
    end
  },
  -- Null-ls for formatters/linters
  { 'jose-elias-alvarez/null-ls.nvim', config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.diagnostics.markdownlint,
          -- add more as needed...
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = 0, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("Format", { clear = true }),
              buffer = bufnr,
              callback = function() vim.lsp.buf.format({ bufnr = bufnr }) end
            })
          end
        end
      })
    end
  },
  -- Autocompletion plugins
  { 'hrsh7th/nvim-cmp', event = 'InsertEnter', config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()  -- load friendly-snippets
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.confirm({ select = true }),  -- confirm selection
          ['<C-Space>'] = cmp.mapping.complete(),              -- manually trigger completion
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' }
        }, {
          { name = 'buffer' },
          { name = 'path' }
        }),
        formatting = {
          format = require('lspkind').cmp_format({ mode = 'symbol_text', maxwidth = 50 })
        }
      })
    end,
    requires = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 
                'hrsh7th/cmp-path', 'saadparwaiz1/cmp_luasnip', 
                'L3MON4D3/LuaSnip', 'rafamadriz/friendly-snippets', 'onsails/lspkind.nvim' }
  },
  -- Rust crates version management
  { 'saecki/crates.nvim', event = { "BufRead Cargo.toml" }, config = true },
}

Rationale: This setup lazy-loads LSP and completion plugins when needed (e.g. InsertEnter for cmp, or on specific file opens for some). It ensures our Rust, Go, TS, HTML, CSS files all get language server intelligence with minimal config in each case. Mason automates external tool setup ￼, and nvim-cmp with LuaSnip gives a rich completion experience, which is crucial for productivity. We’ve included format-on-save for a streamlined workflow (e.g., Rust code formats via rustfmt on save, as is common ￼).

2. Treesitter for Syntax and Code Navigation

Plugin: nvim-treesitter/nvim-treesitter – We will use Tree-sitter for syntax highlighting, indentation, and text object parsing. Treesitter provides more accurate and context-aware highlighting than Vim’s regex-based default ￼, which greatly improves the coding experience (e.g., better highlighting of Rust macros, JS template strings, etc.). We will enable the following via Treesitter:
	•	Highlighting: ensure parsers for rust, go, javascript, typescript, html, css, lua, markdown, etc. are installed. We’ll turn on incremental selection and folding by syntax.
	•	Text objects: include nvim-treesitter-textobjects plugin to get convenient text objects (like “function” or “class” text objects – you can select or move by function, etc., great for power usage).
	•	Context highlighting: (optional) include nvim-treesitter-context to always show the current function or class name at the top of the window as you scroll (useful in deep files).
	•	We will set up Treesitter to auto-install/update parsers and to lazy-load on file open (to avoid slowing startup).

Plugin: nvim-treesitter/nvim-treesitter-textobjects – defines Lua text objects using Treesitter queries (e.g., af = a function, if = inner function, etc.), very handy for structured editing. This plugin is maintained as part of the Treesitter ecosystem.

Plugin: (Optional UI tweak) lukas-reineke/indent-blankline.nvim – draws thin vertical lines at each indent level, which, combined with Treesitter, helps visualize code structure. This is lightweight and improves readability, so we include it as a nice-to-have.

Configuration:

In lua/plugins/devtools.lua (or a treesitter.lua):

return {
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', event = 'BufReadPre', config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'rust', 'go', 'lua', 'vim', 'typescript', 'tsx', 'html', 'css', 'markdown' },
        highlight = { enable = true },
        indent    = { enable = true },
        incremental_selection = { enable = true },
        textobjects = { enable = true },
      }
    end
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' },
  { 'lukas-reineke/indent-blankline.nvim', event = 'BufReadPre', config = function()
      vim.opt.list = true
      require('indent_blankline').setup {
        show_current_context = true,
        show_trailing_blankline_indent = false,
      }
    end 
  },
}

This ensures first-class syntax support for our languages – “better syntax highlighting than the default” is achieved via Treesitter ￼. With Treesitter and its text objects, navigating and editing code (e.g., selecting a Rust function or moving to the next class in JS) becomes intuitive and precise.

3. Fuzzy Finder and File Navigation

Efficient navigation is key for a power user. We will use Telescope for fuzzy finding and related picker menus:
	•	Plugin: nvim-telescope/telescope.nvim – Telescope is a highly extendable fuzzy finder that lets you search files, buffer lines, recent files, LSP symbols, and more with an interactive dropdown interface ￼. It’s a staple in modern Neovim configs for quickly jumping to what you need.
	•	We’ll map <leader>ff to “find file”, <leader>fg to “live grep” across the project, <leader>fb to “find buffer”, etc. This replaces the need for a file tree by providing quick fuzzy search (although we can include a tree as optional, see below).
	•	Include BurntSushi/ripgrep and sharkdp/fd integration (which we already have installed) for fast file search ￼.
	•	We will also add the Telescope extension telescope-fzf-native.nvim (compiled C port of fzf) to further speed up sorting, making searches blazing fast. (This is optional but recommended for performance).
	•	Plugin: nvim-telescope/telescope-fzf-native.nvim – Telescope extension for FZF algorithm, we’ll install it and enable it if available (it needs a make compile; we ensure build tools are installed as noted).
	•	File tree (optional): For those who prefer a side file explorer, we suggest nvim-tree.lua or nvim-neo-tree/neo-tree.nvim. However, since the user did not explicitly ask for one and many power users rely on Telescope instead, we won’t include a tree by default. The built-in netrw can be used (:Explore) for quick file browsing if needed. (Should the user desire a tree, adding one of these plugins is straightforward and both are well-maintained.)

Configuration & Keymaps (Telescope):

In lua/plugins/devtools.lua:

{
  'nvim-telescope/telescope.nvim', cmd = 'Telescope', requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    local telescope = require('telescope')
    telescope.setup{
      defaults = {
        mappings = { i = { ['<C-j>'] = 'move_selection_next', ['<C-k>'] = 'move_selection_previous' } },
        prompt_prefix = "🔍 ",  -- just a fancy icon as prefix
      },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true }
      }
    }
    pcall(telescope.load_extension, 'fzf')
  end
},
{ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable('make') == 1 },

And in lua/config/keymaps.lua:

local map = vim.keymap.set
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'Find Files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>',  { desc = 'Live Grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>',    { desc = 'List Buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<CR>',  { desc = 'Search Help' })

With this, finding files or text is extremely fast and intuitive – press leader+ff and type a few letters to open a file, or leader+fg to grep code. Telescope also provides nice integrations (e.g., you can easily list Git commits or LSP definitions using its built-in pickers). It’s a widely recommended tool in Neovim setups ￼.

4. Git Integration

A power developer needs tight Git integration. We include minimal but powerful Git plugins:
	•	Plugin: tpope/vim-fugitive – Fugitive is the legendary Git plugin for Vim. It allows you to run Git commands from inside Neovim (e.g., :Git commit, :Git push), inspect changes with :Gdiffsplit, and open the Git status window. It’s extremely stable and a must-have for many (often called “the Git hub inside Vim”). We’ll map <leader>gg to :Git (status) for convenience. Fugitive also enables browsing GitHub PRs or issues when paired with tpope/vim-rhubarb (optional).
	•	Plugin: lewis6991/gitsigns.nvim – Gitsigns shows line change indicators (± in the sign column) and allows actions on hunks. We’ll use it for:
	•	Signs in the gutter for added/modified lines.
	•	On-demand blame of a line (virtually or in a popup).
	•	Hunk actions: stage/undo stage hunk, preview hunk diff.
	•	It integrates with Neovim’s async job for performance.
We will configure Gitsigns to update on buffer read and on git events. For keymaps: e.g., [c and ]c to jump between hunks, <leader>hs to stage hunk, <leader>hb to blame line, etc.
	•	Plugin: sindrets/diffview.nvim (optional) – Provides a full Git diff interface in Neovim (side-by-side diffs in tabs, file history view, etc.). This is very useful for code reviews or reviewing commits. We include it as an optional plugin that can be opened via :DiffviewOpen. It’s well-maintained and complements Fugitive (Fugitive’s :Gdiff is 2-way diff for current file; Diffview can show project diffs or history in a tree).

Together, Fugitive and Gitsigns cover “commit tools, blame, diffing” as requested. The Medium article author also lists Fugitive and Gitsigns among “cool plugins” for a complete setup ￼.

Configuration (Gitsigns & keymaps):

In lua/plugins/devtools.lua:

{ 'tpope/vim-fugitive', cmd = { 'Git', 'Gdiffsplit', 'Gblame', 'Gpush', 'Gpull' } },
{ 'lewis6991/gitsigns.nvim', event = 'BufReadPre', config = function()
    require('gitsigns').setup {
      current_line_blame = true,
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end
        map('n', ']c', gs.next_hunk, 'Next Git Hunk')
        map('n', '[c', gs.prev_hunk, 'Prev Git Hunk')
        map('n', '<leader>hs', gs.stage_hunk, 'Stage Hunk')
        map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo Stage Hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset Hunk')
        map('n', '<leader>hb', gs.blame_line, 'Blame Line')
        map('n', '<leader>hd', gs.diffthis, 'Diff This File')
      end
    }
  end
},
{ 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' }, requires = 'nvim-lua/plenary.nvim' },

Keymaps in keymaps.lua:

vim.keymap.set('n', '<leader>gg', '<cmd>Git<CR>', { desc = 'Git status (Fugitive)' })

Using these, you can stay in Neovim for most Git tasks: stage and commit changes, push/pull, view diffs – all without leaving the editor. Gitsigns gives quick inline feedback (signs and optional inline blame) which is invaluable when editing collaboratively or reviewing code ￼. Fugitive is a proven tool for any complex Git tasks (rebases, resolving conflicts, etc. via Vim).

5. Markdown Editing and Preview

For Markdown, we want both editing comfort and an easy way to preview rendered output.
	•	Syntax Highlighting & Editing Aids: We rely on Treesitter for Markdown highlighting (it covers Markdown and even LaTeX fragments, etc.). We will also enable spell-checking in Markdown files and wrap text at 80 columns for writing:
	•	Use an autocommand or filetype plugin to set textwidth=80 and spell in Markdown, so long paragraphs wrap and typos are highlighted.
	•	Consider installing godlygeek/tabular and preservim/vim-markdown if a lot of Markdown tables and TOC are needed, but those are older plugins. A more modern alternative for tables could be the Treesitter-based AckslD/nvim-FeMaco.lua for table formatting, but we’ll skip unless required.
	•	Tip: The plugin bullets.vim can help with automatic list continuation if desired (as mentioned in a 2024 Neovim Markdown guide ￼), but to stay minimal, we omit it by default.
	•	Plugin: iamcco/markdown-preview.nvim – a popular plugin that opens your Markdown file in a browser with live reload. When you run :MarkdownPreview, it launches a local web server and opens the page in your default browser, updating on every save. It supports synchronized scrolling and even math via KaTeX. It’s a lightweight solution since the rendering is done in the browser. We will lazy-load this plugin (only start the server when needed). Despite slow update activity, it remains widely used and functional ￼ (the fact that many are using it is evidenced by queries about its maintenance status).
We’ll ensure to run :call mkdp#util#install() after installing to set up the required Node modules (the plugin is Node-based). We’ll map <leader>mp to start the preview.
	•	Alternative: ellisonleao/glow.nvim – as an alternative, if one prefers in-editor preview using the terminal (powered by the glow CLI), this plugin can be used. It renders Markdown to text with ANSI styling inside a floating window. It’s simple and requires installing the glow command. We note it here, but our main plan will use the browser preview for a more accurate rendering (CSS, images, etc.).

(The user can choose either plugin; both are established. The Reddit community has used Peek.nvim as well for MD preview in a floating web-renderer, which one user added on top of AstroNvim ￼ ￼, but we’ll stick with the proven markdown-preview.nvim for now.)

Configuration:

{ 'iamcco/markdown-preview.nvim', ft = 'markdown', run = 'cd app && npm install', config = function()
    vim.g.mkdp_auto_close = true  -- auto-close preview on buffer close
    vim.g.mkdp_open_to_the_world = false
    vim.g.mkdp_browser = ''       -- use default browser
  end
},

Keymap in keymaps.lua:

vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreview<CR>', { desc = 'Markdown Preview (browser)' })

Now, when editing Markdown, you get all basic editing features plus:
	•	Fenced code blocks highlighted correctly (Treesitter).
	•	TOC generation and linting if marksman LSP is enabled (it will, for example, warn about inconsistent heading levels).
	•	Live preview: just hit <leader>mp and your default browser opens the rendered document. As you save changes in Neovim, the browser auto-refreshes to show updates ￼. This is extremely useful for writing documentation, notes, or README files.

If choosing Glow instead, one would do: {'ellisonleao/glow.nvim', cmd='Glow'} and use :Glow to see an in-Neovim markdown render.

6. Integrated Terminal

Though Neovim is running inside the Ghostty terminal, having an embedded terminal buffer is useful for running build tasks, quick REPLs, or commands without leaving Neovim. We’ll use a plugin to manage this seamlessly:
	•	Plugin: akinsho/toggleterm.nvim – This plugin makes it trivial to open and toggle terminal buffers from inside Neovim. You can configure multiple terminals (horizontal, vertical, floating) and toggle them with a keystroke. We choose it over manually managing :terminal splits because it handles persistence and keymapping nicely.
We will set up a couple of convenient terminals:
	•	A floating terminal (maybe bound to t or <C-\\> hotkey) for quick commands. This can be 80% of the editor size, centered.
	•	A horizontal terminal (maybe 10 lines height) for running a local dev server or continuous build at the bottom.
	•	Toggleterm also supports opening in a new tab or direction as needed, and can assign terminals an index for reuse.
Example mapping: <C-\\> (Ctrl+backslash) to toggle the last terminal. This key is chosen as it’s mnemonic for “terminal” and not heavily used otherwise.

Using Ghostty, one could also split the terminal outside Neovim, but toggleterm allows keeping context (especially with something like running cargo run or npm start and quickly toggling output).

Configuration:

{ 'akinsho/toggleterm.nvim', keys = { [[<C-\>]] }, config = function()
    require('toggleterm').setup{
      open_mapping = [[<C-\>]],
      direction = 'float',  -- default to float
      float_opts = { border = 'curved' }
    }
  end
}

This sets Ctrl-Backslash to toggle a floating terminal window. We can create additional mappings/commands for specific terminals if needed:
	•	e.g., :ToggleTerm direction=horizontal size=10 could be bound to open a bottom terminal.
	•	Or set shell = zsh if needed (Ghostty likely uses user’s default shell anyway).

Now, hitting Ctrl+\ inside Neovim instantly brings up a terminal. You can run builds, use a REPL, etc., then hide it with the same key to go back to coding. The plugin ensures the terminal state persists (so if you started a server, it keeps running in background when hidden). This addresses the requirement for “terminal access inside Neovim.” It’s similar to using a Tmux pane but fully within Neovim.

(Note: In the earlier Rust dev blog, the author used vim-floaterm for similar float terminal needs ￼ – toggleterm.nvim is the modern equivalent.)

7. Aesthetic and Convenience Plugins (UI/UX)

To round out the experience, we add a few lightweight plugins and settings that improve the day-to-day usability of Neovim:
	•	Colorscheme: We will choose a modern colorscheme that supports Tree-sitter and LSP highlighting. Some popular, maintained options:
	•	Catppuccin (catppuccin/nvim) – warm pastel theme with great language support.
	•	Tokyonight (folke/tokyonight.nvim) – a popular theme with vibrant colors.
	•	Gruvbox Material (sainnhe/gruvbox-material) – a classic with Tree-sitter support.
	•	One Dark (navarasu/onedark.nvim) – an Atom One Dark clone with good support.
Ultimately, theme is personal; we’ll include one (say Tokyonight as default) but this can be swapped easily. We ensure true color is on (termguicolors) in options.lua for best appearance.
	•	Statusline: nvim-lualine/lualine.nvim for a minimal status line. Lualine is in Lua, fast, and highly configurable. We’ll set it to show mode, branch, filename, and diagnostics. It can integrate with Git (showing branch via gitsigns) and LSP (showing warnings/errors count). We pick a simple theme (maybe auto from colorscheme). Having a clear statusline improves navigation and context.
	•	folke/which-key.nvim: Which-key pops up a help menu when you press leader (or any prefix), showing available keybindings. This is excellent for discoverability, especially since we plan to set many custom mappings (like <leader> shortcuts for LSP, Git, etc.). Which-key is lazy-loaded on keypress and will prevent “which key did what?” confusion. It’s very user-friendly and doesn’t hinder speed.
	•	Comments: numToStr/Comment.nvim gives easy commenting of code. With it, you can press gcc to toggle comment on a line, or gc in visual mode to comment selection. It’s well-maintained and respects file comment syntax. We’ll include it to quickly comment/uncomment code, which is essential in any dev workflow.
	•	Auto-pairs: windwp/nvim-autopairs auto-closes brackets, quotes, etc., and even integrates with nvim-cmp to auto-complete parentheses. It’s lightweight. This saves time and reduces errors while coding in Rust/Go/JS (all of which have lots of braces/brackets).
	•	Surround: To easily add/change surrounding characters (like quotes, brackets around text), we include kylechui/nvim-surround. It’s a modern take on the classic vim-surround. Example: ysiw" to surround inner word with quotes, cs"' to change surrounding quotes to single quotes, etc. This improves text editing efficiency.
	•	Miscellaneous: We enable set number and set relativenumber (hybrid line numbers) for easy line navigation. We set signcolumn = yes so sign columns (for Gitsigns, diagnostics) don’t shift text. We also enable mouse support (set mouse=a) in case one wants to click in the Ghostty terminal (Ghostty being GUI-ish supports mouse interactions).
	•	MacOS specific keys: We map ⌘+S (Command+S) and Ctrl+S to save the file. By default, terminal Neovim doesn’t recognize the Command key, but Ghostty allows creating custom keybindings with the super (cmd) modifier ￼. We will do the following:
	•	In Neovim, map <C-s> in normal/insert/visual modes to write the file. (We also map <D-s> in Neovim, which will work if the terminal sends it.)
	•	In Ghostty’s config, add a keybind for cmd+s to send a Ctrl+S keystroke (or directly trigger an action to send :w<CR> – but sending Ctrl+S is simpler). This way, when you press ⌘S in Ghostty, Neovim receives Ctrl+S and executes the save mapping. Ghostty’s config uses keybind = cmd+s=text:\x13 (0x13 is Ctrl-S) or similar to accomplish this. In iTerm2, users do something similar (mapping ⌘-s to send :w<CR> or Ctrl-S) ￼; Ghostty supports cmd in keybinds as well ￼.
	•	We ensure to disable terminal flow control so Ctrl+S doesn’t freeze the terminal (in zsh, stty -ixon or setting in Ghostty to not use Ctrl+S/Q for flow). Ghostty by default may not use XON/XOFF, but we mention it just in case.
Similarly, we could map other common macOS shortcuts:
	•	⌘+Q to :qa (quit all),
	•	⌘+C / ⌘+V for copy/paste in visual mode (though Ghostty might handle copy on select anyway).
	•	⌘+F to Telescope find (or maybe leave that to application).
These make Neovim feel more native on macOS. We will implement ⌘S since it was requested, and leave others optional.

Configuration (UI & Keymap highlights):

lua/plugins/ui.lua:

return {
  { 'folke/tokyonight.nvim', config = function() vim.cmd('colorscheme tokyonight-night') end },
  { 'nvim-lualine/lualine.nvim', after = 'tokyonight.nvim', config = function()
      require('lualine').setup {
        options = { theme = 'tokyonight', globalstatus = true },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = { {'filename', path = 1} },
          lualine_x = { 'diagnostics', 'encoding', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        }
      }
    end 
  },
  { 'folke/which-key.nvim', event = 'VeryLazy', config = true },
  { 'numToStr/Comment.nvim', keys = { 'gcc', 'gc', 'gb' }, config = true },
  { 'windwp/nvim-autopairs', event = 'InsertEnter', config = true },
  { 'kylechui/nvim-surround', event = 'BufReadPre', config = true },
}

In lua/config/options.lua:

-- General settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'        -- use system clipboard
vim.opt.termguicolors = true            -- true color support
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true                -- use spaces instead of tabs
vim.opt.shiftwidth = 4                  -- indent size
vim.opt.tabstop = 4
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250                -- faster updates (for CursorHold, etc.)
-- MacOS specific
vim.opt.shell = '/bin/zsh'              -- ensure shell

In lua/config/keymaps.lua (continuing):

-- Leader key
vim.g.mapleader = ' '   -- set leader to Space
-- Save shortcuts
vim.keymap.set({'n','v'}, '<C-s>', ':w<CR>', { desc = 'Save file' })
vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>l', { desc = 'Save file' })  -- in insert, leave insert then save
vim.keymap.set({'n','v'}, '<D-s>', ':w<CR>', { desc = 'Save file (Cmd+S)' })
vim.keymap.set('i', '<D-s>', '<Esc>:w<CR>l', { desc = 'Save file (Cmd+S)' })

(We map Command+S in Neovim for completeness; Ghostty will need to send it. According to Ghostty docs, “super” is recognized as a modifier for keybind triggers ￼, so cmd+s can indeed be captured and forwarded.)

Now pressing Ctrl+S in normal mode or insert mode will save the buffer. In Ghostty, adding a config line like keybind = ctrl+s=ignore (to override flow control if any) and keybind = cmd+s=send:ctrl+s (conceptually) will bridge ⌘S to Neovim. As a result, ⌘+S will behave just like the Save command in a GUI editor – satisfying muscle memory for Mac users.

Why these UI plugins: They each fulfill a quality-of-life role without bloat:
	•	Which-key makes discovering and remembering keybindings easier, which is helpful as our config grows (and it’s optional, loading only when needed).
	•	Lualine gives a clean, informative status line that is common in modern Neovim setups.
	•	Comment.nvim, autopairs, surround are all lightweight and greatly enhance editing efficiency (commenting blocks, auto-closing brackets, modifying surrounding quotes – tasks done countless times daily).
	•	These are “minimal yet powerful” additions that many Neovim users consider essential, and they are all well-maintained.

macOS (Ghostty) Specific Tips

Ghostty is a GPU-accelerated, native-like terminal, so Neovim will run smoothly in it. A few tips to optimize the experience on macOS with Ghostty:
	•	Keybindings in Ghostty: As discussed, to use macOS shortcuts, configure Ghostty’s keybind options. For example, in your ghostty.toml (or GUI settings), add a binding for Command+S to send Ctrl+S to the terminal. Ghostty allows using super (alias for cmd) in keybind triggers ￼. This way, standard Mac shortcuts (save, quit, etc.) can be passed to Neovim. Ghostty’s documentation provides examples for keybinding configurations and how to make them global if desired (with the global: prefix for globally recognized shortcuts) ￼ ￼.
	•	Disable flow control: If you find pressing Ctrl+S freezes the terminal (pauses output), disable XON/XOFF in your shell (stty -ixon) or in Ghostty’s settings. This ensures Ctrl+S only triggers the Neovim mapping and doesn’t get captured by the terminal.
	•	Emoji and Glyph support: Ghostty has special handling for glyphs and emoji – it can render many Nerd Font icons even if your font isn’t patched ￼ ￼. This means our usage of symbols in lualine or diagnostics should display fine. If some icons don’t show, consider switching to a Nerd Font or enabling Ghostty’s glyph support option.
	•	True color & Italics: Ghostty fully supports true-color (24-bit color) and italic text. Our termguicolors is enabled, so the colorscheme will look as intended. If italic comments or such don’t show, ensure Ghostty isn’t overriding the terminfo – Ghostty typically uses its own terminfo that supports these features.
	•	Use macOS features: Ghostty being a native macOS app means you can use macOS shortcuts for window management (e.g., use ⌘+T to open a new Ghostty tab if you want another Neovim instance, ⌘+\ to split panes, etc., as configured in Ghostty). This can complement the in-app splits of Neovim.
	•	Performance: Ghostty is very fast, but if you run into any rendering issues (like flicker), try disabling Neovim’s cursor animations or enabling Ghostty’s GPU synchronization options. In our Neovim config, we set updatetime=250ms to make things like CursorHold and gitsigns updates more responsive without being too frequent.

Best Practices for Performance and Maintainability

Finally, here are some best practices baked into this config to ensure it remains snappy and easy to maintain:
	•	Lazy-loading: Nearly all plugins are set to load only when needed (using lazy.nvim specs for event, cmd, ft, or key triggers). For example, LSP and completions load on insert or file open, Markdown preview loads only for markdown files, etc. This keeps startup time minimal and memory footprint lower. You get a fast startup, with plugins activating on demand.
	•	Profiling/Health: We can use :Lazy profile to check if any plugin is slow to load. Also :checkhealth in Neovim will report any issues (like missing external programs or incorrect settings) ￼. We recommend running :checkhealth after setup to verify all dependencies (e.g., ensure LSP servers are found, etc.).
	•	Pinning versions: As noted, using the lockfile with lazy ensures your plugins don’t update unexpectedly ￼. When you do update (:Lazy update), read the plugin change logs (especially for core ones like nvim-lspconfig or telescope) to adjust config if needed. This avoids breakages.
	•	Minimal plugin set: We intentionally included only popular, well-supported plugins that cover the needed functionality. This reduces maintenance overhead. Each of these has a large user base and is known to work with Neovim 0.11+. For instance, treesitter, telescope, gitsigns, etc., are staples in the community (even the Medium guide author lists these as “essential plugins” ￼). Fewer plugins also means fewer points of failure and faster load.
	•	Splitting config files: As shown, we separated config into logical units. This makes future edits easier – e.g., if a bug arises in completion, you know to look in plugins/lsp.lua. If you want to swap a theme, go to plugins/ui.lua. This clarity itself is a maintainability win (a single giant init.lua can become unwieldy).
	•	Auto-commands and utilities: We add a few niceties:
	•	Auto-format on save (configured via null-ls on_attach as above) to keep code formatted without manual effort.
	•	Possibly an autocommand to highlight yanked text (to visually confirm copy – can add in autocmds.lua).
	•	Persistent undo: setting vim.opt.undofile=true and undodir ensures your undo history persists across sessions, which is great for long-term projects.
	•	If performance ever lags (e.g., very large files), consider using vim.opt.lazyredraw or disabling certain plugins for those filetypes. Our setup already avoids heavy processing on large files (treesitter will not be enabled for files above a certain size by default).
	•	Git and Project integration: Our config respects project-local settings if you use something like .editorconfig (we could add the editorconfig plugin, but Neovim 0.11 supports some editorconfig out of the box via built-in). And since we included Fugitive, interacting with Git submodules or worktrees can be done within Neovim.
	•	Long-term UX: This setup is “minimal yet powerful” – it has all the critical features (LSP, snippets, treesitter, git, file search, terminal, markdown) without extraneous fluff. The user experience should remain consistent and uncluttered. We avoid over-complicating the UI (for instance, we did not add notification popups or fancy command-line UIs that some distros include by default and which some find distracting ￼). We aim for a clean, “Vim-like” experience enhanced with modern plugins. This means as Neovim core evolves, this config should continue to work with minor tweaks, and the user can always customize further to their taste.

By following this plan, you’ll have a Neovim v0.11.1 environment tailored for Rust, Go, and web development that is fast, minimal, and highly functional. All key workflows – coding, navigation, version control, writing docs – are covered with robust tools. And because we chose popular plugins, you can find help or updates from the community easily if needed. Enjoy your new setup, and happy coding!

Sources:
	•	Kickstart.nvim recommended as a minimal base ￼ ￼
	•	Neovim plugin selection (LSP, Treesitter, Telescope, etc.) aligned with community guides ￼ ￼ ￼ ￼
	•	Rust development features enabled by Neovim LSP (rust-analyzer) ￼
	•	Ghostty terminal supports Command-key mappings (treated as “super”) ￼
	•	Markdown preview via browser for live rendering ￼ ￼
	•	Neovim 0.11 new features used (global float border) ￼