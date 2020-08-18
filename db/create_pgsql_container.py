#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput

def run():
    dst = Path.home() / 'db' / 'Postgres' / 'self'
    dst.mkdir(parents=True, exist_ok=True)

    DOCKER_CMD = '''sudo docker run -d \
    --name pgsql \
    --network net \
    -e POSTGRES_PASSWORD=pin105 \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v ~/db/Postgres/self:/var/lib/postgresql/data/pgdata \
    -p 5432:5432 \
    postgres'''

    (status, output) = getstatusoutput(DOCKER_CMD)
    if status != 0:
        print(f"[ERROR] Create Postgres container failed: \n{output}")
        print(f"[ERROR] Fault command: \n    [{DOCKER_CMD}]")
        exit(1)


if __name__ == '__main__':
    run()
