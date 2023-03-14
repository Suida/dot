local luasnip = require 'luasnip'

local s = luasnip.snippet
local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
local c = luasnip.choice_node
local d = luasnip.dynamic_node
local r = luasnip.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

local function copy(args)
  return args[1]
end

local c_cpp_snippets = {
  -- Header guard
  s('hg', {
    t('#ifndef _' ), i(1, 'header_guard'), t('_'),
    t({ '', '#define _' }), f(copy, { 1 }), t('_'),
    t({ '', '', '' }), i(0),
    t({ '', '', '#endif  // _'} ), f(copy, { 1 }), t('_'),
  }),
}

luasnip.add_snippets("c", c_cpp_snippets)
luasnip.add_snippets("cpp", c_cpp_snippets)
