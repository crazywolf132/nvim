---@type LazySpec
return {
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    lazy = false,
    config = function()
      require("mini.icons").mock_nvim_web_devicons()
    end,
    keys = {
      { "ff", function() require("fff").find_files() end, desc = "Find files" },
      { "<leader><leader>", function() require("fff").find_files() end, desc = "Find files" },
    },
  },
  {
    "ibhagwan/fzf-lua",
    opts = {},
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)
      fzf.register_ui_select()
    end,
  },
  { "j-morano/buffer_manager.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  {
    "zefei/vim-wintabs",
    lazy = false,
    init = function()
      vim.g.wintabs_display = "none"
      vim.g.wintabs_autoclose = 1
    end,
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      cleanup_delay_ms = 100,
      use_default_keymaps = true,
      view_options = {
        show_hidden = false,
        is_always_hidden = function(name)
          return vim.startswith(name, ".git")
        end,
      },
      win_options = {
        signcolumn = "auto",
      },
      keymaps = {
        ["<C-s>"] = {
          callback = function()
            require("oil").save()
          end,
          mode = "n",
          desc = "Save changes in Oil",
        },
      },
    },
    dependencies = {
      { "echasnovski/mini.icons", opts = {} },
    },
    lazy = false,
    keys = {
      { "<leader>o", function() require("oil").open() end, desc = "Open oil" },
      { "<leader>e", function() require("oil").open() end, desc = "Open oil" },
    },
  },
  {
    "benomahony/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
    opts = {
      highlights = {
        OilGitAdded = { fg = "#9ccfd8" },
        OilGitModified = { fg = "#f6c177" },
        OilGitRenamed = { fg = "#c4a7e7" },
        OilGitUntracked = { fg = "#31748f" },
        OilGitIgnored = { fg = "#6e6a86" },
      },
    },
    config = function(_, opts)
      require("oil-git").setup(opts)
    end,
  },
  {
    "alex-popov-tech/store.nvim",
    cmd = "Store",
    dependencies = {
      {
        "OXY2DEV/markview.nvim",
        lazy = false,
        opts = {},
      },
    },
    opts = {
      analytics = false,
    },
    keys = {
      { "<leader>ps", function() require("store").open() end, desc = "Open Store.nvim" },
    },
  },
}
