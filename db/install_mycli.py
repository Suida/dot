#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput


def run():
    PIP_CMD = 'pip install mycli'
    (status, output) = getstatusoutput(PIP_CMD)
    if status != 0:
        print("[ERROR] Installing mycli failed: " + output)
        print("[ERROR] Fault command: " + PIP_CMD)
        exit(1)


    cwd = Path(__file__).parent
    home = Path.home()
    src = (cwd / 'mycli-config').absolute()
    dst = (home/'.myclirc').absolute()

    COPY_CMD = f'ln -s { src.absolute() } { dst }'
    (status, output) = getstatusoutput(COPY_CMD)
    if status != 0:
        print(f"[ERROR] Creating soft link of mycli config file failed: \n{output}")
        print(f"[ERROR] Fault command: \n\t[{COPY_CMD}]")
        exit(1)


if __name__ == '__main__':
    run()
