#! /bin/env python
from pathlib import Path
from subprocess import getstatusoutput, call
import create_mysql_container
import create_pgsql_container
import create_redis_container
import install_mycli
import install_pgcli
import install_rdcli


cwd = Path(__file__).parent
bindir = Path.home() / 'bin'


CREATE_SCRIPTS = list(cwd.glob('create-*'))
CLIENT_INSTALL_SCRIPTS = list(cwd.glob('install-*'))
CONNECT_FILES = list(cwd.glob('connect-*'))


def create_containers():
    SCRIPTS = [
        create_mysql_container,
        create_pgsql_container,
        create_redis_container,
    ]
    for each in SCRIPTS:
        each.run()

def install_clients():
    SCRIPTS = [
        install_mycli,
        install_pgcli,
        install_rdcli,
    ]
    for each in SCRIPTS:
        each.run()

def link_connect_scripts_to_bin():
    TARGETS = [ bindir / p.name for p in CONNECT_FILES ]
    for src, dst in zip(CONNECT_FILES, TARGETS):
        dst.symlink_to(src.absolute())

def main():
    create_containers()
    install_clients()
    link_connect_scripts_to_bin()


if __name__ == '__main__':
    main()
