---@type LazySpec
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 900,
    opts = {
      variant = "auto",
      dark_variant = "main",
      enable = {
        terminal = true,
      },
      styles = {
        transparency = true,
      },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dim = { enabled = true },
      bufdelete = { enabled = true },
      dashboard = {
        enabled = true,
        sections = {
          { section = "terminal", cmd = "fortune -s | cowsay", hl = "header", padding = 1, indent = 8 },
          { section = "keys", gap = 1, padding = 1 },
        },
        keys = {
          {
            key = "ff",
            desc = "Find files",
            action = function()
              require("fff").find_files()
            end,
          },
        },
      },
      indent = { enabled = true },
      image = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      toggle = { enabled = true },
      words = { enabled = true },
      zen = { enabled = true },
      terminal = { enabled = true },
      lazygit = { enabled = true, configure = true },
    },
    keys = {
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
      { "<C-\\>", function() Snacks.terminal() end, desc = "Terminal" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      require("config.lualine").init()
    end,
    opts = function()
      return require("config.lualine").opts()
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      require("config.lualine").post_setup()
    end,
  },
  {
    "mluders/comfy-line-numbers.nvim",
    lazy = false,
    opts = {
      target_spacing = 4,
      target_clamp = true,
      use_current = true,
      numbering_style = "relative",
      hidden_file_types = { "undotree", "oil" },
      hidden_buffer_types = { "terminal", "nofile" },
    },
    config = function(_, opts)
      require("comfy-line-numbers").setup(opts)
    end,
  },
  {
    "folke/twilight.nvim",
    opts = {
      dimming = {
        alpha = 0.25,
        inactive = true,
      },
      context = 8,
      expand = { "function", "method", "table", "if_statement" },
      exclude = { "help", "lazy", "mason", "oil", "undotree" },
    },
    keys = {
      { "<leader>tw", "<cmd>Twilight<CR>", desc = "Toggle Twilight" },
    },
  },
  {
    "WTFox/jellybeans.nvim",
    lazy = false,
    priority = 1200,
    opts = {
      transparent = true,
      italics = true,
      bold = true,
      plugins = { auto = true },
    },
    config = function(_, opts)
      require("jellybeans").setup(opts)
      vim.cmd.colorscheme("jellybeans")
    end,
  },
  {
    "mitch1000/backpack.nvim",
    lazy = false,
    priority = 900,
    opts = {
      contrast = "medium",
      commentStyle = { italic = true },
      keywordStyle = { bold = true },
      statementStyle = { bold = true },
      returnStyle = { italic = false, bold = true },
      transparent = true,
      dimInactive = false,
      terminalColors = true,
    },
    config = function(_, opts)
      require("backpack").setup(opts)
    end,
  },
}
