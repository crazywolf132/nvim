-- Minimal yet powerful Neovim config (nightly-ready)

-- Use faster Lua module loader (Neovim 0.9+; improves startup)
pcall(function()
  if vim.loader and vim.loader.enable then
    vim.loader.enable()
  end
end)

-- Leader keys must be set before plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core settings and mappings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require("lazy").setup({ import = "plugins" }, {
  ui = { border = "rounded" },
  change_detection = { enabled = true, notify = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  defaults = { lazy = true },
})

