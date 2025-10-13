---@type LazySpec
return {
  {
    "folke/which-key.nvim",
    lazy = false,
    priority = 900,
    config = function()
      require("config.whichkey").setup()
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("todo-comments").setup(opts)
    end,
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>st", "<cmd>TodoQuickFix<CR>", desc = "Todo quickfix" },
    },
  },
  {
    "mattn/emmet-vim",
    ft = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "sass",
      "scss",
      "typescript",
      "typescriptreact",
    },
    init = function()
      vim.g.user_emmet_install_global = 0
      vim.g.user_emmet_leader_key = "<C-e>"
      vim.g.user_emmet_settings = {
        javascript = { extends = "jsx" },
        typescript = { extends = "tsx" },
        javascriptreact = { extends = "jsx" },
        typescriptreact = { extends = "tsx" },
      }
    end,
    config = function()
      local group = vim.api.nvim_create_augroup("EmmetAttach", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "css",
          "html",
          "javascript",
          "javascriptreact",
          "sass",
          "scss",
          "typescript",
          "typescriptreact",
        },
        callback = function()
          vim.cmd.EmmetInstall()
        end,
      })
    end,
  },
  {
    "mbbill/undotree",
    init = function()
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_SplitWidth = 40
      vim.g.undotree_DiffpanelHeight = 15
    end,
    keys = {
      { "<leader>u", function() vim.cmd.UndotreeToggle() end, desc = "Toggle Undotree" },
    },
  },
  {
    "nguyenvukhang/nvim-toggler",
    event = "VeryLazy",
    opts = {
      remove_default_keybinds = true,
    },
    config = function(_, opts)
      require("nvim-toggler").setup(opts)
    end,
    keys = {
      {
        "<leader>tb",
        function()
          require("nvim-toggler").toggle()
        end,
        desc = "Toggle word/boolean under cursor",
        mode = { "n", "v" },
      },
    },
  },
  {
    "jbyuki/venn.nvim",
    cmd = { "VBox" },
    keys = {
      {
        "<leader>vd",
        function()
          require("config.venn").toggle()
        end,
        desc = "Toggle venn drawing mode",
        mode = { "n" },
      },
      {
        "<leader>vb",
        function()
          require("config.venn").draw_box()
        end,
        desc = "Draw box/line with venn",
        mode = { "v" },
      },
    },
  },
}
