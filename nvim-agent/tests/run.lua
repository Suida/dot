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
agent.setup({ main_agent = false })  -- keymaps only; no auto-spawn in tests

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

section('persist + recovery')
local agent3 = require('agent')
local persist = require('agent.persist')
agent3._root = vim.fn.getcwd()

agent3.spawn('r1', { cmd = 'cat' })
persist.save()
local m = persist.load()
T.eq(m.version, 1, 'manifest version')
T.eq(m.clean_exit, false, 'clean_exit false after save')
T.eq(#m.workers, 1, 'manifest has worker')
T.eq(m.workers[1].id, 'r1', 'manifest worker id')

persist.mark_clean_exit()
T.eq(persist.load().clean_exit, true, 'mark_clean_exit works')

-- corrupt manifest -> nil + no crash
local cf = io.open('.agent/session.json', 'w'); cf:write('{not json'); cf:close()
T.eq(persist.load(), nil, 'corrupt manifest returns nil')

-- crash-note prompt builder
T.ok(agent3._crash_prompt('z1', '.agent/tasks/z1.md'):match('crashed') ~= nil,
  'crash prompt mentions crash')

-- recovery: worker without resume template (agent 'cat') respawns fresh.
-- task_file = nil so no prompt arg is appended to the `cat` cmdline.
local cf2 = io.open('.agent/session.json', 'w')
cf2:write(vim.json.encode({
  version = 1, clean_exit = false,
  workers = { { id = 'z1', agent = 'cat', cmd = 'cat', cwd = vim.fn.getcwd(),
                task_file = nil, op_overrides = {}, visible = false } },
  foreground = 'z1',
}))
cf2:close()
agent3._config.auto_recover = 'always'
agent3._maybe_recover()
local z = require('agent.registry').get('z1')
T.ok(z ~= nil, 'recovered worker registered')
T.ok(require('agent.registry').alive(z), 'recovered worker alive')
T.eq(agent3._foreground, 'z1', 'foreground restored')
agent3.kill('z1')

-- recovery via resume template: preset with `resume` spawns the resume cmd.
-- No shipped preset resumes into a harmless command, so inject a fake one.
require('agent.presets').user = { fakecat = { resume = 'cat' } }
local cf3 = io.open('.agent/session.json', 'w')
cf3:write(vim.json.encode({
  version = 1, clean_exit = false,
  workers = { { id = 'z9', agent = 'fakecat', cmd = 'fakecat', cwd = vim.fn.getcwd(),
                op_overrides = {}, visible = false } },
}))
cf3:close()
agent3._config.auto_recover = 'always'
agent3._maybe_recover()
local z9 = require('agent.registry').get('z9')
T.ok(z9 ~= nil, 'resume-template worker registered')
T.ok(require('agent.registry').alive(z9), 'resume-template worker alive (resume cmd spawned)')
agent3.kill('z9')
require('agent.presets').user = {}

agent3.kill('r1')
os.remove('.agent/session.json')

section('sessions')
local sessions = require('agent.sessions')
local idx = vim.fn.tempname()
local idxf = io.open(idx, 'w')
idxf:write(vim.json.encode({ sessionId = 's1', workDir = 'C:/Foo/Bar' }) .. '\n')
idxf:close()
T.ok(sessions.kimi_session_ids('c:\\foo\\bar', idx)['s1'], 'index parsed, slash/case normalized')
T.eq(sessions.kimi_session_ids('/elsewhere', idx)['s1'], nil, 'other cwd excluded')
local before = sessions.kimi_session_ids('c:\\foo\\bar', idx)
local got
sessions.capture_kimi('c:\\foo\\bar', before, function(id) got = id end, idx, 5)
idxf = io.open(idx, 'a')
idxf:write(vim.json.encode({ sessionId = 's2', workDir = 'C:/foo/bar' }) .. '\n')
idxf:close()
vim.wait(3000, function() return got ~= nil end, 100)
T.eq(got, 's2', 'capture finds session created after snapshot')
os.remove(idx)

-- recovery prefers session-targeted resume, keeping the worker's original args
require('agent.presets').user = { fakecat = { resume = 'bogus-fallback', resume_suffix = '--session {session}' } }
local cf4 = io.open('.agent/session.json', 'w')
cf4:write(vim.json.encode({
  version = 1, clean_exit = false,
  workers = { { id = 'z7', agent = 'fakecat', cmd = 'cat', cwd = vim.fn.getcwd(),
                session_id = 'abc123', op_overrides = {}, visible = false } },
}))
cf4:close()
agent3._config.auto_recover = 'always'
agent3._maybe_recover()
local z7 = require('agent.registry').get('z7')
T.ok(z7 ~= nil, 'session-resume worker registered')
T.eq(z7 and z7.cmd, 'cat --session abc123', 'resume_suffix applied to original cmd')
T.ok(z7 and require('agent.registry').alive(z7), 'session-resume worker alive')
agent3.kill('z7')
require('agent.presets').user = {}
os.remove('.agent/session.json')

section('main agent auto-open')
local agent4 = require('agent')
agent4.setup({ main_agent = 'cat' })
vim.wait(500, function() return require('agent.registry').get('main') ~= nil end)
local mw = require('agent.registry').get('main')
T.ok(mw ~= nil, 'main agent spawned on setup')
T.ok(mw and require('agent.registry').alive(mw), 'main agent alive')
T.eq(agent4._foreground, 'main', 'main agent foregrounded')
agent4.kill('main')
T.eq(require('agent.registry').get('main'), nil, 'main agent killed')

print(('\n%d passed, %d failed'):format(T.pass, T.fail))
if T.fail > 0 then vim.cmd('cquit 1') end
vim.cmd('qa!')
