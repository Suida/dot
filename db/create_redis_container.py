#! /bin/env python
from sys import exit
from pathlib import Path
from subprocess import getstatusoutput

def run():
    dst = Path.home() / 'db' / 'Redis' / 'self'
    conf = dst.parent / 'redis.conf'

    dst.mkdir(parents=True, exist_ok=True)
    conf.touch(exist_ok=True)

    DOCKER_CMD = ''' sudo docker run -d \
    --name redis \
    --network net \
    -v ~/db/Redis/redis.conf:/usr/local/etc/redis/redis.conf \
    -v ~/db/Redis/self:/data \
    -p 6379:6379 \
    redis redis-server /usr/local/etc/redis/redis.conf'''

    (status, output) = getstatusoutput(DOCKER_CMD)
    if status != 0:
        print(f"[ERROR] Create Redis container failed: \n{output}")
        print(f"[ERROR] Fault command: \n    [{DOCKER_CMD}]")
        exit(1)


if __name__ == '__main__':
    run()
