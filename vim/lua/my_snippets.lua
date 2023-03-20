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
  s({
    trig = '#ifndef _header_guard_',
    name = 'Snippet for C/C++ header guard macro',
  }, {
    t('#ifndef _' ), i(1, 'header_guard'), t('_'),
    t({ '', '#define _' }), f(copy, { 1 }), t('_'),
    t({ '', '', '' }), i(0),
    t({ '', '', '#endif  // _'} ), f(copy, { 1 }), t('_'),
  }),
  s({
    trig = '#ifdef condition',
    name = 'Snippet for C/C++ condition macro',
  }, {
    t('#ifdef ' ), i(1, 'condition'),
    t({ '', '', '' }), i(0),
    t({ '', '', '#endif  // '} ), f(copy, { 1 }),
  }),
  s({
    trig = 'if (condition)',
    name = 'Snippet for C/C++ if statement',
  }, {
    t('if (' ), i(1, 'condition'), t(') {'),
    t({ '', '  ' }), i(2),
    t({ '', '}', ''} ), i(0),
  }),
  s({
    trig = 'if-else',
    name = 'Snippet for C/C++ if-else statement',
  }, {
    t('if (' ), i(1, 'condition'), t(') {'),
    t({ '', '  ' }), i(2),
    t({ '', '} else {',} ),
    t({ '', '  ' }), i(3),
    t({ '', '}', ''} ), i(0),
  }),
  s({
    trig = 'if-elif',
    name = 'Snippet for C/C++ if-elif statement',
  }, {
    t('if (' ), i(1, 'condition'), t(') {'),
    t({ '', '  ' }), i(3),
    t({ '', '} else if (',} ), i(2), t(') {'),
    t({ '', '  ' }), i(4),
    t({ '', '} else {',} ),
    t({ '', '  ' }), i(5),
    t({ '', '}', ''} ), i(0),
  }),
  s({
    trig = 'elif',
    name = 'Snippet for C/C++ elif statement',
  }, {
    t({ 'else if (',} ), i(1), t(') {'),
    t({ '', '  ' }), i(2),
    t({ '', '}',} ),
  }),
}

luasnip.add_snippets("c", c_cpp_snippets)
luasnip.add_snippets("cpp", c_cpp_snippets)
