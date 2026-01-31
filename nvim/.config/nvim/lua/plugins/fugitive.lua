return {
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit" },
  keys = {
    { "<leader>gb", "<cmd>Git blame<cr>" },
    { "<leader>gd", "<cmd>Gdiffsplit<cr>" },
  },
}
