#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput


def run():
    src = Path('rdcli')
    dst = Path.home() / 'bin' / 'rdcli'
    dst.symlink_to(src.absolute())


if __name__ == '__main__':
    run()
