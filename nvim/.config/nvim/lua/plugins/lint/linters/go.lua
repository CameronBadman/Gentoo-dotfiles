return {
  linters = { "golangcilint" },
  custom = {
    golangcilint = {
      cmd = "golangci-lint",
      stdin = false,
      args = {
        "run",
        "--output.json.path=stdout",
        "--show-stats=false",
        "--enable=asasalint",
        "--enable=asciicheck",
        "--enable=bidichk",
        "--enable=bodyclose",
        "--enable=canonicalheader",
        "--enable=containedctx",
        "--enable=contextcheck",
        "--enable=copyloopvar",
        "--enable=cyclop",
        "--enable=decorder",
        "--enable=dogsled",
        "--enable=dupl",
        "--enable=dupword",
        "--enable=durationcheck",
        "--enable=err113",
        "--enable=errcheck",
        "--enable=errchkjson",
        "--enable=errname",
        "--enable=errorlint",
        "--enable=exhaustive",
        "--enable=exptostd",
        "--enable=fatcontext",
        "--enable=forcetypeassert",
        "--enable=funlen",
        "--enable=gochecknoglobals",
        "--enable=gochecknoinits",
        "--enable=gocognit",
        "--enable=goconst",
        "--enable=gocritic",
        "--enable=gocyclo",
        "--enable=godot",
        "--enable=godox",
        "--enable=goprintffuncname",
        "--enable=gosec",
        "--enable=gosmopolitan",
        "--enable=grouper",
        "--enable=iface",
        "--enable=importas",
        "--enable=inamedparam",
        "--enable=ineffassign",
        "--enable=interfacebloat",
        "--enable=intrange",
        "--enable=ireturn",
        "--enable=lll",
        "--enable=maintidx",
        "--enable=makezero",
        "--enable=mirror",
        "--enable=misspell",
        "--enable=mnd",
        "--enable=musttag",
        "--enable=nakedret",
        "--enable=nestif",
        "--enable=nilerr",
        "--enable=nilnesserr",
        "--enable=nilnil",
        "--enable=nlreturn",
        "--enable=noctx",
        "--enable=nonamedreturns",
        "--enable=nosprintfhostport",
        "--enable=perfsprint",
        "--enable=prealloc",
        "--enable=predeclared",
        "--enable=promlinter",
        "--enable=reassign",
        "--enable=recvcheck",
        "--enable=revive",
        "--enable=rowserrcheck",
        "--enable=sloglint",
        "--enable=spancheck",
        "--enable=sqlclosecheck",
        "--enable=tagliatelle",
        "--enable=thelper",
        "--enable=unconvert",
        "--enable=unparam",
        "--enable=usestdlibvars",
        "--enable=varnamelen",
        "--enable=wastedassign",
        "--enable=whitespace",
        "--enable=wrapcheck",
        "--enable=wsl_v5",
        function()
          return vim.fn.expand("%:p:h")
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        if output == "" then
          return {}
        end

        local json_end = output:find("}\n")
        if json_end then
          output = output:sub(1, json_end)
        end

        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded or not decoded.Issues then
          return {}
        end

        local diagnostics = {}
        local filename = vim.api.nvim_buf_get_name(bufnr)

        for _, issue in ipairs(decoded.Issues) do
          if vim.fn.fnamemodify(issue.Pos.Filename, ":p") == filename then
            table.insert(diagnostics, {
              lnum = issue.Pos.Line - 1,
              col = issue.Pos.Column - 1,
              end_lnum = issue.Pos.Line - 1,
              end_col = issue.Pos.Column,
              severity = vim.diagnostic.severity.WARN,
              source = issue.FromLinter,
              message = issue.Text,
            })
          end
        end

        return diagnostics
      end,
    },
  },
}
