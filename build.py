#! /usr/bin/env python
from pathlib import Path
from subprocess import getstatusoutput


st, ot = getstatusoutput('git')
assert st == 1, 'Git has not been installed!'
