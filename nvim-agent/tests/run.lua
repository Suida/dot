-- Resolve this script's dir so tests can run from any cwd.
local run_src = debug.getinfo(1, 'S').source:sub(2):gsub('\\', '/')
dofile(vim.fn.fnamemodify(run_src, ':h') .. '/test_init.lua')

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

section('registry')
local reg = require('agent.registry')
local e1 = { id = 'w1', buf = 10, job = 5, agent = 'kimi', cmd = 'kimi',
             cwd = '/tmp', task_file = nil, op_overrides = {} }
local e2 = { id = 'w2', buf = 11, job = 6, agent = 'codex', cmd = 'codex',
             cwd = '/tmp', task_file = nil, op_overrides = {} }
reg.add('w1', e1)
reg.add('w2', e2)
T.eq(reg.get('w1'), e1, 'get returns entry')
T.eq(#reg.list(), 2, 'list length')
T.eq(reg.by_index(2), e2, 'by_index respects insertion order')
local dup = pcall(reg.add, 'w1', e1)
T.eq(dup, false, 'duplicate add errors')
local ser = reg.serialize()
T.eq(ser[1].id, 'w1', 'serialize id')
T.eq(ser[1].buf, nil, 'serialize omits buf (JSON-safe)')
reg.remove('w1')
T.eq(reg.get('w1'), nil, 'remove works')
T.eq(#reg.list(), 1, 'list after remove')
reg.remove('w2')

section('core api')
local agent = require('agent')
agent.setup({})  -- registers keymaps; harmless headless

local res, err = agent.spawn('t1', { cmd = '"' .. vim.v.progpath .. '" --headless -u NONE +qa' })
T.ok(res and res.buf and res.job, 'spawn returns buf/job')
T.ok(vim.api.nvim_buf_is_valid(res.buf), 'worker buffer valid')
T.eq(vim.api.nvim_buf_get_name(res.buf):match('agent://worker/t1$') ~= nil, true, 'buffer named agent://worker/t1')

local dupres, duperr = agent.spawn('t1', { cmd = 'kimi' })
T.eq(dupres, nil, 'duplicate spawn fails')
T.ok(duperr:match('duplicate') ~= nil, 'duplicate error message')

local badres, baderr = agent.spawn('t2', { cmd = 'definitely-not-a-real-cmd-xyz' })
T.eq(badres, nil, 'non-executable spawn fails')
T.ok(baderr:match('not found') ~= nil, 'PATH error message')

-- Let the test job exit BEFORE any window ops: on Windows, headless nvim
-- segfaults when a terminal job exits after the window showing its buffer
-- has been closed (core bug); exiting first avoids it.
vim.fn.jobwait({ res.job }, 2000)

T.eq(agent.focus('t1'), true, 'focus ok')
T.ok(require('agent.registry').visible(require('agent.registry').get('t1')), 'visible after focus')
T.eq(agent.hide('t1'), true, 'hide ok')
T.eq(require('agent.registry').visible(require('agent.registry').get('t1')), false, 'hidden after hide')

-- status file parsing
vim.fn.mkdir('.agent/status', 'p')
local sf = io.open('.agent/status/t1.md', 'w')
sf:write('state: blocked\nneed input on X\n')
sf:close()
local st = agent.status('t1')
T.eq(st.state, 'blocked', 'status state parsed')
T.ok(st.summary:match('need input') ~= nil, 'status summary parsed')
T.eq(agent.status('t1').alive, false, 'dead job reported (nvim +qa exited)')
T.eq(agent.status('nope'), nil, 'status of unknown id errors')
os.remove('.agent/status/t1.md')

T.eq(agent.kill('t1'), true, 'kill ok')
T.eq(require('agent.registry').get('t1'), nil, 'unregistered after kill')

print(('\n%d passed, %d failed'):format(T.pass, T.fail))
if T.fail > 0 then vim.cmd('cquit 1') end
vim.cmd('qa!')
