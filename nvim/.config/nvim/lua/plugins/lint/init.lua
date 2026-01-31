return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      local linters_path = vim.fn.stdpath("config") .. "/lua/plugins/lint/linters"

      for _, file in ipairs(vim.fn.readdir(linters_path)) do
        if file:match("%.lua$") then
          local ft = file:gsub("%.lua$", "")
          local linter_config = require("plugins.lint.linters." .. ft)
          lint.linters_by_ft[ft] = linter_config.linters

          if linter_config.custom then
            for name, config in pairs(linter_config.custom) do
              lint.linters[name] = config
            end
          end
        end
      end

      vim.api.nvim_create_autocmd("BufReadPost", {
        callback = function()
          local ft = vim.bo.filetype
          if lint.linters_by_ft[ft] then
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
