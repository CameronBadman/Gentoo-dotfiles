return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
  },
  init = function()
    if vim.treesitter.language.get_lang then
      vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
    end
  end,
  config = function()
    require("telescope").load_extension("fzf")
  end,
}
