#!/bin/bash

echo 'mysql-server mysql-server/root_password password' root | debconf-set-selections
echo 'mysql-server mysql-server/root_password_again password' root | debconf-set-selections
apt-get install -y mysql-server

# Create db structure
# if [ -z /var/lib/mysql/xfera ] ; then
service mysql restart
echo "Creating db <xfera>"
mysql -uroot -proot --execute "CREATE USER 'xfera'@'localhost' IDENTIFIED BY 'xfera';"
mysql -uroot -proot --execute "CREATE DATABASE xfera CHARACTER SET utf8;"
mysql -uroot -proot --execute "CREATE DATABASE xfera_test DEFAULT CHARACTER SET utf8;"
mysql -uroot -proot --execute "CREATE DATABASE xfera_mock DEFAULT CHARACTER SET utf8;"
mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_test.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_mock.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
sleep 5
echo "END of db creation <xfera>"
# else
#     echo "DB <xfera> was already there."
# fi

# sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts

# db_assets_path="/mnt/docker/scripts/db/"
# db_dump_file_production="database_dump.sql"

echo "Running needed rake instructions..."
rake db:create \
    && rake db:permissions:recreate \
    && rake db:permissions:create_acgp_fixtures \
    && echo "Rake instructions have been executed."

echo "STARTING REDIS..."
redis-server --daemonize yes
ps aux | grep "[r]edis-server" && echo "REDIS started successfully." || echo "REDIS not found."


echo "FIXING TCP connection to localhost:35729."
# awk 'NR==2 {$0="::1 localhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/"} 1' /etc/hosts  # Not working fine.
cp /etc/hosts /etc/hosts.new && \
sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts.new && \
cp -f /etc/hosts.new /etc/hosts

# DB DUMPS
# echo "Executing dump..."
# mysql -uxfera -pxfera xfera < "$db_assets_path$db_dump_file_production" \
# && echo "Dump done"
