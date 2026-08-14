#!/usr/bin/env bash
# fake-agent.sh <status-file>: stdin-echoing stand-in for a CLI agent.
set -u
STATUS=${1:?status file path required}
mkdir -p "$(dirname "$STATUS")"
printf 'state: working\nfake agent ready\n' > "$STATUS"
while IFS= read -r line; do
  printf 'heard: %s\n' "$line" >> "$STATUS"
  case "$line" in
    *DONE*) sed -i.bak '1s/.*/state: done/' "$STATUS" && rm -f "$STATUS.bak" ;;
  esac
done
