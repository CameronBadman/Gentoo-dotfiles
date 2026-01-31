local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

ls.add_snippets("go", {
  s("iferr", {
    t("if err != nil {"),
    t({ "", "\treturn " }),
    c(1, {
      t("err"),
      { t("fmt.Errorf(\""), i(1), t(": %w\", err)") },
      { i(1), t(", err") },
    }),
    t({ "", "}" }),
  }),

  s("ife", {
    t("if err := "),
    i(1),
    t("; err != nil {"),
    t({ "", "\treturn " }),
    c(2, {
      t("err"),
      { t("fmt.Errorf(\""), i(1), t(": %w\", err)") },
    }),
    t({ "", "}" }),
  }),

  s("st", {
    t("type "),
    i(1, "Name"),
    t({ " struct {", "\t" }),
    i(2),
    t({ "", "}" }),
  }),

  s("iface", {
    t("type "),
    i(1, "Name"),
    t({ " interface {", "\t" }),
    i(2),
    t({ "", "}" }),
  }),

  s("meth", {
    t("func ("),
    i(1, "r"),
    t(" "),
    i(2, "Receiver"),
    t(") "),
    i(3, "Method"),
    t("("),
    i(4),
    t(") "),
    i(5),
    t({ " {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("fn", {
    t("func "),
    i(1, "name"),
    t("("),
    i(2),
    t(") "),
    i(3),
    t({ " {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("ctx", {
    t("ctx context.Context"),
  }),

  s("ctxp", {
    t("ctx, cancel := context.WithCancel("),
    i(1, "context.Background()"),
    t({ ")", "defer cancel()" }),
  }),

  s("ctxt", {
    t("ctx, cancel := context.WithTimeout("),
    i(1, "context.Background()"),
    t(", "),
    i(2, "time.Second"),
    t({ ")", "defer cancel()" }),
  }),

  s("errf", {
    t("fmt.Errorf(\""),
    i(1),
    t(": %w\", "),
    i(2, "err"),
    t(")"),
  }),

  s("tst", {
    t("func Test"),
    i(1, "Name"),
    t({ "(t *testing.T) {", "\ttestCases := []struct {", "\t\tname string", "\t\t" }),
    i(2),
    t({ "", "\t}{", "\t\t{", "\t\t\tname: \"" }),
    i(3),
    t({ "\",", "\t\t}," }),
    t({ "", "\t}", "", "\tfor _, tc := range testCases {", "\t\tt.Run(tc.name, func(t *testing.T) {", "\t\t\t" }),
    i(0),
    t({ "", "\t\t})", "\t}", "}" }),
  }),

  s("bench", {
    t("func Benchmark"),
    i(1, "Name"),
    t({ "(b *testing.B) {", "\tfor i := 0; i < b.N; i++ {", "\t\t" }),
    i(0),
    t({ "", "\t}", "}" }),
  }),

  s("fori", {
    t("for "),
    i(1, "i"),
    t(" := "),
    i(2, "0"),
    t("; "),
    f(function(args) return args[1][1] end, { 1 }),
    t(" < "),
    i(3, "n"),
    t("; "),
    f(function(args) return args[1][1] end, { 1 }),
    t({ "++ {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("forr", {
    t("for "),
    i(1, "k"),
    t(", "),
    i(2, "v"),
    t(" := range "),
    i(3),
    t({ " {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("sel", {
    t({ "select {", "case " }),
    i(1),
    t({ ":", "\t" }),
    i(2),
    t({ "", "default:", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("swt", {
    t("switch "),
    i(1),
    t({ " {", "case " }),
    i(2),
    t({ ":", "\t" }),
    i(3),
    t({ "", "default:", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("json", {
    t("`json:\""),
    i(1),
    t("\"`"),
  }),

  s("hf", {
    t("func "),
    i(1, "handler"),
    t({ "(w http.ResponseWriter, r *http.Request) {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  s("defr", {
    t("defer func() {"),
    t({ "", "\t" }),
    i(0),
    t({ "", "}()" }),
  }),

  s("gof", {
    t("go func() {"),
    t({ "", "\t" }),
    i(0),
    t({ "", "}()" }),
  }),

  s("make", {
    t("make("),
    c(1, {
      { t("[]"), i(1, "T") },
      { t("map["), i(1, "K"), t("]"), i(2, "V") },
      { t("chan "), i(1, "T") },
    }),
    t(", "),
    i(2, "0"),
    t(")"),
  }),

  s("pf", {
    t("fmt.Printf(\""),
    i(1),
    t("\\n\""),
    i(2),
    t(")"),
  }),

  s("pl", {
    t("fmt.Println("),
    i(1),
    t(")"),
  }),
})
