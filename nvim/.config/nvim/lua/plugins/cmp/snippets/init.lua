local M = {}

function M.setup()
  local snippets_path = vim.fn.stdpath("config") .. "/lua/plugins/cmp/snippets"
  local ok, files = pcall(vim.fn.readdir, snippets_path)
  if not ok or not files then
    return
  end
  for _, file in ipairs(files) do
    if file:match("%.lua$") and file ~= "init.lua" then
      local lang = file:gsub("%.lua$", "")
      require("plugins.cmp.snippets." .. lang)
    end
  end
end

return M
