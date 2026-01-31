return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local map = function(mode, l, r)
        vim.keymap.set(mode, l, r, { buffer = bufnr })
      end
      map("n", "]h", gs.next_hunk)
      map("n", "[h", gs.prev_hunk)
      map("n", "<leader>hp", gs.preview_hunk)
      map("n", "<leader>hr", gs.reset_hunk)
      map("n", "<leader>hs", gs.stage_hunk)
    end,
  },
}
