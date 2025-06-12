-- plugins/sage.lua
-- Sage SCM integration plugin

return {
  {
    'sage-scm/sage.nvim',
    dependencies = {
      'folke/which-key.nvim', -- For command discoverability
    },
    config = true, -- Use default configuration
    -- Alternatively, you can customize:
    -- opts = {
    --   leader = '<leader>G', -- Use different leader key
    -- }
  },
}