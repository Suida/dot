#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput


def run():
    APT_CMD = 'sudo apt install libpq-dev'
    (status, output) = getstatusoutput(APT_CMD)
    if status != 0:
        print("[ERROR] Installing pre-requirement libpq-dev failed: " + output)
        print("[ERROR] Fault command: " + APT_CMD)
        exit(1)


    PIP_CMD = 'pip install pgcli'
    (status, output) = getstatusoutput(PIP_CMD)
    if status != 0:
        print("[ERROR] Installing pgcli failed: " + output)
        print("[ERROR] Fault command: " + PIP_CMD)
        exit(1)


    src = Path(__file__).parent / 'pgcli-config'
    dst = Path.home() / '.config' / 'pgcli' / 'config'

    dst.parent.mkdir(parents=True, exist_ok=True)

    COPY_CMD = f'ln -s { src.absolute() } { dst.absolute() }'
    (status, output) = getstatusoutput(COPY_CMD)
    if status != 0:
        print("[ERROR] Creating soft link of mycli config file failed: " + output)
        print("[ERROR] Fault command: " + COPY_CMD)


if __name__ == '__main__':
    run()
