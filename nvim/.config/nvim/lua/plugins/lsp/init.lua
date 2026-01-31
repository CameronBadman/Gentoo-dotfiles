return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "golangci_lint_ls" },
      })

      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 2,
        },
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      local keymaps = require("plugins.lsp.keymaps")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers_path = vim.fn.stdpath("config") .. "/lua/plugins/lsp/servers"
      for _, file in ipairs(vim.fn.readdir(servers_path)) do
        if file:match("%.lua$") then
          local server_name = file:gsub("%.lua$", "")
          local opts = require("plugins.lsp.servers." .. server_name)
          opts.on_attach = keymaps.on_attach
          opts.capabilities = capabilities
          vim.lsp.config(server_name, opts)
          vim.lsp.enable(server_name)
        end
      end
    end,
  },
}
