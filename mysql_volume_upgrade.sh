#!/bin/bash

set -eu
set -o pipefail

export VOLUME_NAME_TEMP="jobins_base_mysql_volume_temp"
docker volume rm $VOLUME_NAME_TEMP -f || true
docker volume create --name $VOLUME_NAME_TEMP
docker run --network host --rm --name percona-xtrabackup --user 0:0 --cap-add=sys_nice --volumes-from mysql_8 -v $VOLUME_NAME_TEMP:/backup percona/percona-xtrabackup:8.0.35 xtrabackup --backup --register-redo-log-consumer --datadir=/var/lib/mysql --target-dir=/backup --host=127.0.0.1 --port=3308 --user=root --password=password

echo "copy data"
export VOLUME_NAME="jobins_base_mysql_volume"
docker volume rm $VOLUME_NAME -f || true
docker volume create --name $VOLUME_NAME
docker run --rm -v $VOLUME_NAME_TEMP:/backup -v $VOLUME_NAME:/var/lib/mysql alpine ash -c 'cd /backup ; cp -av . /var/lib/mysql'