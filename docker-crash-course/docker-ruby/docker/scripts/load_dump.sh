#!/usr/bin/env bash

DB_NAME=${DBSS_DB_NAME:=xfera}
DB_USER=${DBSS_DB_USER:=root}
DB_PASS=${DBSS_DB_PASS:=root}

DB_FILENAME='./docker/scripts/db/database_dump.sql'
USE_FILE='n'
if [ -e ${DB_FILENAME} ];
then
     read -p "There is a sql dump file on the default path ($DB_FILENAME). Do you want to use it? [y/N] " USE_FILE
fi
if [ "${USE_FILE,,}" = "y" ];
then
    echo -e "Loading sql dump file from: $DB_FILENAME"
    #mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} < ${DB_FILENAME}
    result=$(mysql --silent -u${DB_USER} -p${DB_PASS} -D${DB_NAME} < ${DB_FILENAME})
    if [ $? -eq "0" ]; then
        echo -e "Sql file loaded!"
    fi
else
    read -p "Do you want to load a dump sql file? Type path or please enter [s] to skip " SQL_DUMP_PATH
    case "$SQL_DUMP_PATH" in
        s)
            echo -e "Sql dump not loaded!"
        ;;

        "")
            echo -e "Sql dump file not provided!"
        ;;

        *)
            echo -e "Loading sql dump file from: $SQL_DUMP_PATH"
            result=$(mysql -u${DB_USER} -p${DB_PASS} ${DB_NAME} < ${SQL_DUMP_PATH})
            if [ $? -eq "0" ]; then
                echo -e "Sql file loaded!"
            fi
        ;;
    esac
fi
