---@type LazySpec
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = {
      { "Bilal2453/luvit-meta", lazy = true },
    },
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim" } },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "*",
          package_pending = ">",
          package_uninstalled = "x",
        },
      },
      PATH = "prepend",
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local lsp = require("config.lsp")
      lsp.setup_autocmd()
      local servers = vim.deepcopy(lsp.servers or {})

      local ensure = {}
      for name in pairs(servers) do
        table.insert(ensure, name)
      end
      table.sort(ensure)

      local capabilities = lsp.capabilities()
      local on_attach = lsp.on_attach

      local use_new_api = type(vim.lsp) == "table"
        and type(vim.lsp.config) == "function"
        and type(vim.lsp.enable) == "function"

      if use_new_api then
        vim.lsp.config("*", {
          capabilities = capabilities,
          on_attach = on_attach,
        })

        for name, conf in pairs(servers) do
          vim.lsp.config(name, conf)
        end
      end

      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup({
        ensure_installed = ensure,
        automatic_installation = true,
        handlers = use_new_api and nil or {
          function(server_name)
            local ok, lspconfig = pcall(require, "lspconfig")
            if not ok or not lspconfig[server_name] then
              vim.notify(
                ("LSP server %q is not supported by nvim-lspconfig"):format(server_name),
                vim.log.levels.WARN,
                { title = "LSP" }
              )
              return
            end

            local server_opts = vim.tbl_deep_extend(
              "force",
              {},
              servers[server_name] or {},
              {
                capabilities = capabilities,
                on_attach = on_attach,
              }
            )

            lspconfig[server_name].setup(server_opts)
          end,
        },
      })

      if use_new_api then
        for _, name in ipairs(ensure) do
          vim.lsp.enable(name)
        end
      end

      vim.diagnostic.config({
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      {
        "<leader>ld",
        function()
          require("trouble").toggle("diagnostics")
        end,
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>le",
        function()
          require("trouble").toggle("diagnostics", {
            filter = { severity = vim.diagnostic.severity.ERROR },
          })
        end,
        desc = "Errors (Trouble)",
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach",
    opts = {
      text = {
        spinner = "dots",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/schemastore.nvim",
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = function()
      local lsp = require("config.lsp")
      return {
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          lsp.on_attach(client, bufnr)
        end,
        capabilities = lsp.capabilities(),
        settings = {
          expose_as_code_action = "all",
          complete_function_calls = true,
          tsserver_file_preferences = {
            includeCompletionsForModuleExports = true,
            includeCompletionsWithSnippetText = true,
            includeCompletionsWithClassMemberSnippets = true,
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            jsxAttributeCompletionStyle = "auto",
          },
        },
      }
    end,
    config = function(_, opts)
      require("typescript-tools").setup(opts)
    end,
  },
  {
    "saecki/crates.nvim",
    event = { "BufReadPre Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local crates = require("crates")
      crates.setup({})

      local group = vim.api.nvim_create_augroup("CratesExtras", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = group,
        pattern = "Cargo.toml",
        callback = function(event)
          local ok, mapped = pcall(vim.api.nvim_buf_get_var, event.buf, "crates_mapped")
          if ok and mapped then return end

          local function buf_map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          buf_map("<leader>cu", crates.update_crate, "Update crate under cursor")
          buf_map("<leader>cU", crates.update_all_crates, "Update all crates")
          buf_map("<leader>cv", crates.show_versions_popup, "Show crate versions")
          buf_map("<leader>cf", crates.show_features_popup, "Show crate features")
          buf_map("<leader>cd", crates.open_documentation, "Open crate documentation")

          vim.api.nvim_buf_set_var(event.buf, "crates_mapped", true)
        end,
      })
    end,
  },
}
