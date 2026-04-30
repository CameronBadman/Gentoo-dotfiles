return {
  linters = { "ruff", "mypy" },
  custom = {
    ruff = {
      cmd = "ruff",
      stdin = false,
      args = {
        "check",
        "--output-format=json",
        "--select=E,F,W,I,N,UP,B,A,C4,T10,T20,RET,SIM,ARG,PTH,PL,RUF",
        "--ignore=D,ANN,COM812,ISC001,PLR0913,PLR2004,PLR0915",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        if output == "" then
          return {}
        end
        local ok, decoded = pcall(vim.json.decode, output)
        if not ok or not decoded then
          return {}
        end
        local diagnostics = {}
        local filename = vim.api.nvim_buf_get_name(bufnr)
        for _, issue in ipairs(decoded) do
          if vim.fn.fnamemodify(issue.filename, ":p") == filename then
            local severity = vim.diagnostic.severity.WARN
            if issue.code and issue.code:match("^E") then
              severity = vim.diagnostic.severity.ERROR
            end
            table.insert(diagnostics, {
              lnum = issue.location.row - 1,
              col = issue.location.column - 1,
              end_lnum = issue.end_location.row - 1,
              end_col = issue.end_location.column - 1,
              severity = severity,
              source = "ruff[" .. (issue.code or "?") .. "]",
              message = issue.message,
            })
          end
        end
        return diagnostics
      end,
    },
    mypy = {
      cmd = "mypy",
      stdin = false,
      args = {
        "--output=json",
        "--warn-unreachable",
        "--warn-redundant-casts",
        "--warn-unused-ignores",
        "--no-implicit-optional",
        function()
          return vim.api.nvim_buf_get_name(0)
        end,
      },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output, bufnr)
        if output == "" then
          return {}
        end
        local diagnostics = {}
        local filename = vim.api.nvim_buf_get_name(bufnr)
        for line in output:gmatch("[^\n]+") do
          local ok, issue = pcall(vim.json.decode, line)
          if ok and issue and vim.fn.fnamemodify(issue.file, ":p") == filename then
            local severity_map = {
              error = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              note = vim.diagnostic.severity.INFO,
            }
            table.insert(diagnostics, {
              lnum = (issue.line or 1) - 1,
              col = (issue.column or 1) - 1,
              end_lnum = (issue.end_line or issue.line or 1) - 1,
              end_col = (issue.end_column or issue.column or 1) - 1,
              severity = severity_map[issue.severity] or vim.diagnostic.severity.WARN,
              source = "mypy",
              message = issue.message,
            })
          end
        end
        return diagnostics
      end,
    },
  },
}
