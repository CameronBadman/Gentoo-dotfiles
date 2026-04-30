local dafny_bin = vim.fn.exepath("dafny")
if dafny_bin == "" then
  for _, p in ipairs({
    "/usr/bin/dafny",
    "/usr/local/bin/dafny",
    vim.fn.expand("~/.dotnet/tools/dafny"),
  }) do
    if vim.fn.filereadable(p) == 1 then
      dafny_bin = p
      break
    end
  end
end

local z3_bin = vim.fn.exepath("z3")

local cmd = dafny_bin ~= "" and { dafny_bin, "server" } or { "dafny", "server" }
if z3_bin ~= "" then
  vim.list_extend(cmd, { "--solver-path", z3_bin })
end

return {
  cmd = cmd,
  filetypes = { "dafny" },
  root_markers = { "dfyconfig.toml", ".git" },
}
