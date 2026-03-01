return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      local conform = require("conform")
      local formatters_path = vim.fn.stdpath("config") .. "/lua/plugins/format/formatters"
      local formatters_by_ft = {}
      for _, file in ipairs(vim.fn.readdir(formatters_path)) do
        if file:match("%.lua$") then
          local ft = file:gsub("%.lua$", "")
          local config = require("plugins.format.formatters." .. ft)
          formatters_by_ft[ft] = config
        end
      end
      conform.setup({
        formatters_by_ft = formatters_by_ft,
        format_on_save = {
          timeout_ms = 3000,
          lsp_format = "fallback",
        },
      })
    end,
  },
}
