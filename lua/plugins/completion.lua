local env = require("config.env")
local use_supermaven = env.uses_supermaven()

---@type LazySpec[]
local plugins = {
  {
    "saghen/blink.cmp",
    build = "cargo build --release",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            should_show_items = function(ctx)
              local start_col = ctx.bounds and ctx.bounds.start_col or 1
              if start_col <= 1 then return true end

              local line = ctx.line or ""
              local previous_char = line:sub(start_col - 1, start_col - 1)
              return previous_char ~= "."
            end,
          },
        },
      },
      fuzzy = {
        implementation = "rust",
        frecency = {
          enabled = true,
          path = vim.fn.stdpath("state") .. "/blink-cmp/frecency/frecency.dat",
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "supermaven-inc/supermaven-nvim",
    enabled = use_supermaven,
    event = "InsertEnter",
    cmd = {
      "SupermavenStart",
      "SupermavenStop",
      "SupermavenToggle",
      "SupermavenRestart",
    },
    opts = {
      log_level = "off",
      disable_keymaps = true,
    },
    config = function(_, opts)
      local supermaven = require("supermaven-nvim")
      supermaven.setup(opts)

      local completion = require("supermaven-nvim.completion_preview")
      local termcodes = function(str)
        return vim.api.nvim_replace_termcodes(str, true, false, true)
      end

      vim.keymap.set("i", "<C-]>", function()
        if completion.has_suggestion() then
          vim.schedule(function()
            completion.on_accept_suggestion()
          end)
          return ""
        end
        return termcodes("<C-]>")
      end, { expr = true, silent = true, desc = "Supermaven accept suggestion" })
    end,
  },
}

if not use_supermaven then
  table.insert(plugins, {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = false,
        },
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      local suggestion = require("copilot.suggestion")
      local termcodes = function(str)
        return vim.api.nvim_replace_termcodes(str, true, false, true)
      end

      vim.keymap.set("i", "<C-]>", function()
        if suggestion.is_visible() then
          suggestion.accept()
          return ""
        end
        return termcodes("<C-]>")
      end, { expr = true, silent = true, desc = "Copilot accept suggestion" })
    end,
  })
end

return plugins
