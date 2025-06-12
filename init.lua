-- init.lua
-- Main entry point for Neovim configuration
-- Minimal, powerful setup for Rust, Go, and Web development on macOS (Ghostty Terminal)

-- Set leader keys early
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load core configuration
require('config.options')
require('config.keymaps')
require('config.autocmds')

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")
