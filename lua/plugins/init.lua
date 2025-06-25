-- plugins/init.lua
-- Plugin manager setup and configuration
-- This file is loaded by lazy.nvim to discover all plugin specifications

return {
  -- Import all plugin configurations
  { import = "plugins.lsp" },
  { import = "plugins.ui" },
  { import = "plugins.devtools" },
  
  -- Build status plugin (local plugin)
  {
    dir = vim.fn.stdpath("config") .. "/lua/custom/build-status",
    name = "build-status",
    config = function()
      require("custom.build-status").setup()
    end,
  },
}
