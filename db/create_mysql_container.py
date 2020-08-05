#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput

def run():
    dst = Path.home() / 'db' / 'MySQL' / 'self'
    dst.mkdir(parents=True, exist_ok=True)

    DOCKER_CMD = '''sudo docker run -d \
    --name mysql \
    --network net \
    -e MYSQL_ROOT_PASSWORD=pin105 \
    -v ~/db/MySQL/self:/var/lib/mysql \
    -p 3306:3306 \
    mysql'''

    (status, output) = getstatusoutput(DOCKER_CMD)
    if status != 0:
        print(f"[ERROR] Create Mysql container failed: \n{output}")
        print(f"[ERROR] Fault command: \n    [{DOCKER_CMD}]")
        exit(1)


if __name__ == '__main__':
    run()
