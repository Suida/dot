#! /bin/env bash
awk '$0 !~ /^"/ && $0 !~ /^\s*$/ {s+=1} END {print s}' vim/init.vim
