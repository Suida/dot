#! /bin/env python
from pathlib import Path
from subprocess import getstatusoutput


def run():
    dir = Path.home() / 'bin'
    dir.mkdir(parents=True, exist_ok=True)
    src = Path(__file__).parent / 'rdcli'
    dst = dir / 'rdcli'
    dst.symlink_to(src.absolute())


if __name__ == '__main__':
    run()
