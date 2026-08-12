dofile('nvim-agent/tests/test_init.lua')

local T = { pass = 0, fail = 0 }
function T.eq(got, want, msg)
  if vim.deep_equal(got, want) then
    T.pass = T.pass + 1
  else
    T.fail = T.fail + 1
    print(('FAIL %s\n  want: %s\n  got:  %s'):format(msg, vim.inspect(want), vim.inspect(got)))
  end
end
function T.ok(v, msg) T.eq(not not v, true, msg) end
local function section(name) print('== ' .. name) end

section('presets')
local presets = require('agent.presets')

-- default fallback for unknown agent
local p = presets.resolve('nonexistent-agent', '/nonexistent-root')
T.eq(p.interrupt, '<C-c>', 'default interrupt')
T.eq(p.submit, '<CR>', 'default submit')
T.eq(p.newline, '<C-j>', 'default newline')

-- codex overrides newline, keeps other defaults, has resume
local c = presets.resolve('codex', '/nonexistent-root')
T.eq(c.newline, '<A-CR>', 'codex newline override')
T.eq(c.interrupt, '<C-c>', 'codex inherits interrupt')
T.eq(c.resume, 'codex resume --last', 'codex resume template')

-- kimi resume template
T.eq(presets.resolve('kimi', '/nonexistent-root').resume, 'kimi --continue', 'kimi resume')

-- user layer beats shipped
presets.user = { default = { interrupt = '<C-x>' }, codex = { newline = '<C-CR>' } }
local u = presets.resolve('codex', '/nonexistent-root')
T.eq(u.interrupt, '<C-x>', 'user default op wins')
T.eq(u.newline, '<C-CR>', 'user agent op wins')
presets.user = {}

-- spawn overrides beat everything
local s = presets.resolve('kimi', '/nonexistent-root', { newline = '<M-CR>' })
T.eq(s.newline, '<M-CR>', 'spawn override wins')

-- project layer: write a real .agent/presets.lua
local root = vim.fn.tempname()
vim.fn.mkdir(root .. '/.agent', 'p')
local f = io.open(root .. '/.agent/presets.lua', 'w')
f:write('return { codex = { newline = "<F5>" } }')
f:close()
T.eq(presets.resolve('codex', root).newline, '<F5>', 'project layer wins over shipped')

-- malformed project file falls back, does not error
f = io.open(root .. '/.agent/presets.lua', 'w')
f:write('this is not lua')
f:close()
T.eq(presets.resolve('codex', root).newline, '<A-CR>', 'malformed project file ignored')

-- ops listing excludes resume and is sorted
T.eq(presets.ops({ submit = 1, interrupt = 1, newline = 1, resume = 'x' }),
  { 'interrupt', 'newline', 'submit' }, 'ops sorted, resume excluded')

print(('\n%d passed, %d failed'):format(T.pass, T.fail))
if T.fail > 0 then vim.cmd('cquit 1') end
vim.cmd('qa!')
