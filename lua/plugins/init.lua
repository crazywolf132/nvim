-- plugins/init.lua
-- Plugin manager setup and configuration
-- This file is loaded by lazy.nvim to discover all plugin specifications

return {
  -- Import all plugin configurations
  { import = "plugins.lsp" },
  { import = "plugins.ui" },
  { import = "plugins.devtools" },
}
