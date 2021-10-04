#!/bin/bash

function startMariaDBContainer() {
    echo "[INFO] Starting/configuring MariaDB..."
    docker run -itd -v $(pwd):/mnt --net=net_control -e MYSQL_ROOT_PASSWORD='root' -p 3306:3306 --name mariadb mariadb

    echo "Waiting to MariaDB start... " && sleep 20

    echo "[INFO] Creating DB"
    docker container exec -it mariadb sh /mnt/docker/scripts/create_db.sh
    # docker run -it --network net_control mariadb sh -c 'exec mysql -h"mariadb" -P"3306" -uroot -p"root"'

}

