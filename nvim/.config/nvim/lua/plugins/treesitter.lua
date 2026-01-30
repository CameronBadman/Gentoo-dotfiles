return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "query", "go" })
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        local ignored = {
          "neo-tree", "neo-tree-popup", "notify", "TelescopePrompt",
          "lazy", "lazy_backdrop", "mason", "help", "checkhealth",
        }
        if vim.tbl_contains(ignored, ev.match) then
          return
        end

        pcall(vim.treesitter.start)

        local lang = vim.treesitter.language.get_lang(ev.match)
        local installed = require("nvim-treesitter").get_installed()
        local available = require("nvim-treesitter").get_available()
        if lang and not vim.tbl_contains(installed, lang) and vim.tbl_contains(available, lang) then
          require("nvim-treesitter").install(lang)
        end
      end,
    })
  end,
}
