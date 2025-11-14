local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- prr: public required
  s("prr", {
    t("public required "),
  }),

  -- xit: [Fact]<CR>public void
  -- This creates a basic XUnit/NUnit test method structure.
  s("xit", {
    t("[Fact]"),
    t({ "", "public void " }),
    i(1, "TestName"), -- <i(1)>: Cursor lands here for the test name
    t("()"),
    t({ "", "{" }),
    t({ "\t" }),
    i(0), -- <i(0)>: Final stop, usually inside the brackets
    t({ "", "}" }),
  }),

  -- cclass: internal sealed class
  s("cclass", {
    t("internal sealed class "),
    i(1, "ClassName"), -- <i(1)>: Cursor lands here for the class name
    t({ "", "{" }),
    t({ "\t" }),
    i(0), -- <i(0)>: Final stop
    t({ "", "}" }),
  }),

  -- rrecord: internal sealed record class
  s("rrecord", {
    t("internal sealed record class "),
    i(1, "RecordName"), -- <i(1)>: Cursor lands here for the record name
    t({ "" }),
    i(0), -- <i(0)>: Final stop
    t(";"),
  }),

  -- pclass: private sealed class
  s("pclass", {
    t("private sealed class "),
    i(1, "ClassName"), -- <i(1)>: Cursor lands here for the class name
    t({ "", "{" }),
    t({ "\t" }),
    i(0), -- <i(0)>: Final stop
    t({ "", "}" }),
  }),

  -- precord: private sealed record class
  s("precord", {
    t("private sealed record class "),
    i(1, "RecordName"), -- <i(1)>: Cursor lands here for the record name
    t({ "" }),
    i(0), -- <i(0)>: Final stop
    t(";"),
  }),
}
