---@type LazySpec
return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "folke/snacks.nvim",
    },
    opts = {
      default_remote = { "origin", "upstream" },
      picker = "snacks",
      mappings_disable_default = false,
    },
    keys = {
      { "<leader>go", "<cmd>Octo actions<CR>", desc = "Octo actions" },
      { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "List issues" },
      { "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List pull requests" },
      { "<leader>gN", "<cmd>Octo issue create<CR>", desc = "Create issue" },
      { "<leader>gn", "<cmd>Octo notification list<CR>", desc = "Notifications" },
    },
    config = function(_, opts)
      require("octo").setup(opts)
    end,
  },
}
