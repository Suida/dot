# Notes of DBMS Management

## Scripts to Create DB's Docker Container

### Mysql
```shell
$ sudo docker run -d \
        --name mysql \
        --network net \
        -e MYSQL_ROOT_PASSWORD=pin105 \
        -v ~/db/MySQL/self:/var/lib/mysql \
        -p 3306:3306 \
        mysql
```

### PostgreSQL
```shell
$ sudo docker run -d \
        --name pgsql \
        --network net \
        -e POSTGRES_PASSWORD=pin105 \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        -v ~/db/Postgres/self:/var/lib/postgresql/data/pgdata \
        -p 5432:5432 \
        postgres
```


### Redis
```shell
$ sudo docker run -d \
        --name redis \
        --network net \
        -v ~/db/Redis/redis.conf:/usr/local/etc/redis/redis.conf \
        -v ~/db/Redis/self:/data \
        -p 6379:6379 \
        redis redis-server /usr/local/etc/redis/redis.conf
```

## Connect to The Containers

### Mysql

For mysql, python package `mycli` is recommanded:
```bash
pip install mycli
```

### PostgreSQL

For postgresql, python package `pgcli` is recommanded:
```bash
sudo apt install libpq-dev  # required for pg_config
pip install pgcli
```

### Redis

As for redis, the native client redis image contains is enough to use. The
`rdcli` script is to run it and connect to redis server container.
```bash
chmod 755 rdcli
./rdcli
```
