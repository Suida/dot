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

section('steering')
local agent2 = require('agent')
local reg2 = require('agent.registry')

-- long-lived cat job echoes what we send; we assert on job liveness + no errors
local sp = agent2.spawn('s1', { cmd = 'cat' })
T.ok(sp ~= nil, 'spawn cat')
T.eq(agent2.send('s1', 'hello'), true, 'send literal')
T.eq(agent2.op('s1', 'newline'), true, 'op newline (kimi default preset)')
T.eq(agent2.prompt('s1', 'do thing'), true, 'prompt = send+submit')
T.eq(agent2.send_keys('s1', '<C-c>'), true, 'raw send-keys')
local oplist = agent2.ops('s1')
T.ok(vim.tbl_contains(oplist, 'interrupt'), 'ops lists interrupt')

-- spawn-override lands in resolution: agent name is 'cat' -> default preset,
-- override replaces interrupt
local sp2 = agent2.spawn('s2', { cmd = 'cat', op_overrides = { interrupt = '<C-x>' } })
T.ok(sp2 ~= nil, 'spawn s2')
T.eq(agent2.op('s2', 'interrupt'), true, 'op with spawn override resolves')

-- unknown op error lists available ops
local okbad, errbad = agent2.op('s1', 'nonexistent_op')
T.eq(okbad, nil, 'unknown op fails')
T.ok(errbad:match('available') ~= nil and errbad:match('interrupt') ~= nil,
  'unknown op error lists ops')

-- dead job rejection includes state
agent2.kill('s2') -- kill removes entry; use a killed job differently:
local sp3 = agent2.spawn('s3', { cmd = '"' .. vim.v.progpath .. '" --headless -u NONE +qa' })
vim.fn.jobwait({ sp3.job }, 2000) -- let it exit
vim.fn.mkdir('.agent/status', 'p')
local f3 = io.open('.agent/status/s3.md', 'w'); f3:write('state: working\nmid-task\n'); f3:close()
local oks, errs = agent2.send('s3', 'x')
T.eq(oks, nil, 'send to dead job fails')
T.ok(errs:match('working') ~= nil, 'dead-job error includes last state')
os.remove('.agent/status/s3.md')
agent2.kill('s1')
agent2.kill('s3')

section('ctl dispatch')
local ctl = require('agent.ctl')
local function call(...)
  local args = { ... }
  local lines = {}
  for _, a in ipairs(args) do lines[#lines + 1] = vim.base64.encode(a) end
  return vim.json.decode(ctl.run(table.concat(lines, '\n')))
end

local r = call('spawn', 'c1', '--cmd', 'cat')
T.eq(r.ok, true, 'ctl spawn ok')
T.ok(r.data.buf > 0, 'ctl spawn returns buf')

r = call('spawn', 'c1', '--cmd', 'cat')
T.eq(r.ok, false, 'ctl duplicate spawn errors')

r = call('list')
T.eq(r.ok, true, 'ctl list ok')
T.eq(#r.data, 1, 'ctl list one worker')
T.eq(r.data[1].id, 'c1', 'ctl list id')

r = call('send', 'c1', 'line one\nline two') -- newline survives double-base64
T.eq(r.ok, true, 'ctl send with embedded newline')

r = call('op', 'c1', 'newline')
T.eq(r.ok, true, 'ctl op')

r = call('spawn', 'c2', '--cmd', 'cat', '--op', 'newline=<F6>')
T.eq(r.ok, true, 'ctl spawn with --op')
r = call('ops', 'c2')
T.eq(r.ok, true, 'ctl ops ok')
T.ok(vim.tbl_contains(r.data, 'newline'), 'ctl ops includes newline')

r = call('bogus-command')
T.eq(r.ok, false, 'unknown command errors')
T.ok(r.error:match('unknown command') ~= nil, 'unknown command message')

r = call('focus', 'missing')
T.eq(r.ok, false, 'focus unknown id errors')

call('kill', 'c1')
call('kill', 'c2')

print(('\n%d passed, %d failed'):format(T.pass, T.fail))
if T.fail > 0 then vim.cmd('cquit 1') end
vim.cmd('qa!')
