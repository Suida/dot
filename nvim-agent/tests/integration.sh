#!/usr/bin/env bash
set -euo pipefail
REPO=$(cd "$(dirname "$0")/../.." && pwd)
WORK=$(mktemp -d)
cd "$WORK"

PASS=0; FAIL=0
check() { # check <desc> <expected-substring> <actual>
  if [[ "$3" == *"$2"* ]]; then PASS=$((PASS+1));
  else FAIL=$((FAIL+1)); echo "FAIL: $1"; echo "  want substring: $2"; echo "  got: $3"; fi
}

# boot headless cockpit
# Windows: a terminal job's ConPTY input only works when the nvim process owns
# a console. Under automation (no console attached) chansend bytes never reach
# the worker. Boot via a hidden console window there; plain background on Unix.
NVIM_PID=""
if [[ "${OSTYPE:-}" == msys || "${OSTYPE:-}" == cygwin ]]; then
  INIT_WIN=$(cygpath -w "$REPO/nvim-agent/tests/iterm_init.lua")
  NVIM_PID=$(powershell.exe -NoProfile -Command \
    "\$env:NVIM_APPNAME='nvim-agent'; (Start-Process -PassThru -WindowStyle Hidden -FilePath (Get-Command nvim.exe).Source -ArgumentList '--headless','-u','$INIT_WIN').Id" \
    | tr -d '\r')
  stop_nvim() { taskkill //PID "$NVIM_PID" //F //T >/dev/null 2>&1 || true; }
else
  NVIM_APPNAME=nvim-agent nvim --headless -u "$REPO/nvim-agent/tests/iterm_init.lua" &
  NVIM_PID=$!
  stop_nvim() { kill "$NVIM_PID" 2>/dev/null || true; }
fi
cleanup() {
  stop_nvim
  cd / 2>/dev/null || true # $WORK is our cwd; Windows cannot remove a busy dir
  sleep 0.8
  rm -rf "$WORK" 2>/dev/null || true
}
trap cleanup EXIT

for _ in $(seq 1 50); do [ -e .agent/nvim.sock ] && break; sleep 0.1; done
CTL="$REPO/nvim-agent/bin/agent-ctl"

OUT=$("$CTL" spawn w1 --cmd "bash $REPO/nvim-agent/tests/fake-agent.sh $WORK/.agent/status/w1.md")
check "spawn" '"ok":true' "$OUT"
sleep 0.5 # let the fake agent write its initial status file

OUT=$("$CTL" list)
check "list shows worker" '"id":"w1"' "$OUT"
check "list state working" '"state":"working"' "$OUT"

OUT=$("$CTL" send w1 "hello world")
check "send" '"ok":true' "$OUT"
OUT=$("$CTL" op w1 newline) # send only types; submit the line
check "op newline" '"ok":true' "$OUT"
sleep 0.8
check "fake agent heard" 'hello world' "$(cat .agent/status/w1.md)"

OUT=$("$CTL" prompt w1 "please mark DONE")
check "prompt" '"ok":true' "$OUT"
sleep 0.8
check "state done" 'state: done' "$(cat .agent/status/w1.md)"

OUT=$("$CTL" op w1 interrupt)
check "op interrupt" '"ok":true' "$OUT"

OUT=$("$CTL" status w1)
check "status" '"state":"done"' "$OUT"

OUT=$("$CTL" spawn w1 --cmd cat || true)
check "duplicate rejected" '"ok":false' "$OUT"

OUT=$("$CTL" focus w1)
check "focus" '"ok":true' "$OUT"
OUT=$("$CTL" hide w1)
check "hide" '"ok":true' "$OUT"

OUT=$("$CTL" kill w1)
check "kill" '"ok":true' "$OUT"
OUT=$("$CTL" list)
check "empty after kill" '"data":[]' "$OUT"

OUT=$(cd / && "$CTL" list 2>&1 || true)
check "no socket error" 'no nvim-agent instance found' "$OUT"

# --- crash recovery ---
OUT=$("$CTL" spawn r1 --cmd "bash $REPO/nvim-agent/tests/fake-agent.sh $WORK/.agent/status/r1.md")
check "spawn r1" '"ok":true' "$OUT"
"$CTL" focus r1 >/dev/null

# Simulate crash: force-kill the server so no VimLeavePre runs and the
# manifest stays dirty (clean_exit=false).
if [[ "${OSTYPE:-}" == msys || "${OSTYPE:-}" == cygwin ]]; then
  taskkill //PID "$NVIM_PID" //F //T >/dev/null 2>&1 || true
else
  kill -9 "$NVIM_PID" 2>/dev/null || true
  wait "$NVIM_PID" 2>/dev/null || true
fi

# Reboot with the recovery init (auto_recover=always). Same hidden-console
# Start-Process path on Windows as the initial boot.
if [[ "${OSTYPE:-}" == msys || "${OSTYPE:-}" == cygwin ]]; then
  INIT_WIN=$(cygpath -w "$REPO/nvim-agent/tests/iterm_init_recover.lua")
  NVIM_PID=$(powershell.exe -NoProfile -Command \
    "\$env:NVIM_APPNAME='nvim-agent'; (Start-Process -PassThru -WindowStyle Hidden -FilePath (Get-Command nvim.exe).Source -ArgumentList '--headless','-u','$INIT_WIN').Id" \
    | tr -d '\r')
else
  NVIM_APPNAME=nvim-agent nvim --headless -u "$REPO/nvim-agent/tests/iterm_init_recover.lua" &
  NVIM_PID=$!
fi
# Wait for the new server: on Windows .agent/nvim.sock is a stale pointer file
# until the new server rewrites it, so poll the RPC instead of the file.
OUT=""
for _ in $(seq 1 100); do
  OUT=$("$CTL" list 2>/dev/null || true)
  [[ "$OUT" == *'"ok":true'* ]] && break
  sleep 0.2
done
check "recovery re-registers worker" '"id":"r1"' "$OUT"
check "recovered worker visible" '"visible":true' "$OUT"
"$CTL" kill r1 >/dev/null || true

echo "$PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
