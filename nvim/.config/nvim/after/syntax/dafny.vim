if exists("b:current_syntax")
  finish
endif

" ── Keywords ──────────────────────────────────────────────────────────────────
syn keyword dafnyDecl       method function predicate lemma twostate class trait
syn keyword dafnyDecl       datatype codatatype newtype type module import opens
syn keyword dafnyDecl       abstract opaque ghost static protected const
syn keyword dafnyDecl       constructor iterator

syn keyword dafnySpec       requires ensures modifies reads decreases invariant
syn keyword dafnySpec       returns yields witness by

syn keyword dafnyStatement  var if then else while for in match case
syn keyword dafnyStatement  return break continue assert assume expect print
syn keyword dafnyStatement  new this old fresh allocated calc reveal forall exists

syn keyword dafnyKeyword    import export extends refines as label
syn keyword dafnyKeyword    null true false

syn keyword dafnyType       int nat real bool char string
syn keyword dafnyType       array seq set iset multiset map imap object

" ── Operators & special ───────────────────────────────────────────────────────
syn match   dafnyOperator   "[+\-*/<>=!&|^~?]"
syn match   dafnyOperator   ":="
syn match   dafnyOperator   "==>"
syn match   dafnyOperator   "<==>"
syn match   dafnyOperator   "\.\."

" ── Comments ──────────────────────────────────────────────────────────────────
syn region  dafnyComment    start="/\*" end="\*/" contains=dafnyTodo
syn match   dafnyComment    "//.*$"    contains=dafnyTodo
syn keyword dafnyTodo       contained TODO FIXME NOTE HACK XXX

" ── Strings & chars ───────────────────────────────────────────────────────────
syn region  dafnyString     start='"' skip='\\"' end='"'
syn match   dafnyChar       "'[^'\\]\|\\.[^']*'"

" ── Numbers ───────────────────────────────────────────────────────────────────
syn match   dafnyNumber     "\<[0-9][0-9_]*\>"
syn match   dafnyNumber     "\<0x[0-9a-fA-F][0-9a-fA-F_]*\>"

" ── Highlight links ───────────────────────────────────────────────────────────
hi def link dafnyDecl       Keyword
hi def link dafnySpec       PreProc
hi def link dafnyStatement  Statement
hi def link dafnyKeyword    Special
hi def link dafnyType       Type
hi def link dafnyOperator   Operator
hi def link dafnyComment    Comment
hi def link dafnyTodo       Todo
hi def link dafnyString     String
hi def link dafnyChar       Character
hi def link dafnyNumber     Number

let b:current_syntax = "dafny"
