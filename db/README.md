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
