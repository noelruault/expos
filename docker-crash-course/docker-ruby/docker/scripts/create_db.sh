#!/bin/bash

user="root"
pw="root"

app_name=$1
# Create db structure
# if [ -z /var/lib/mysql/xfera ] ; then
service mysql start
echo "Creating db <xfera>"
mysql -uroot -proot --execute "CREATE USER 'xfera'@'localhost' IDENTIFIED BY 'xfera';"

mysql -uroot -proot --execute "CREATE DATABASE xfera CHARACTER SET utf8;"
mysql -uroot -proot --execute "CREATE DATABASE xfera_test DEFAULT CHARACTER SET utf8;"
mysql -uroot -proot --execute "CREATE DATABASE xfera_mock DEFAULT CHARACTER SET utf8;"

mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_test.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_mock.* TO 'xfera'@'localhost' WITH GRANT OPTION;"
echo "END of db creation <xfera>"
service mysql stop
# else
#     echo "DB <xfera> was already there."
# fi

echo "FIXING TCP connection to localhost:35729."
awk 'NR==2 {$0="::1 ip6-localhost ip6-loopback"} 1' /etc/hosts
# sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts

# db_assets_path="/mnt/docker/scripts/db/"
# db_dump_file_production="database_dump.sql"
# db_dump_file_staging="database_dump.sql"

# cd /mnt/newton && bundle exec rake db:create \
#   && bundle exec rake db:permissions:recreate \
#   && bundle exec rake db:permissions:create_acgp_fixtures

# DB DUMPS
# echo "Executing Production dump..."
# mysql -uxfera -pxfera xfera < "$db_assets_path$db_dump_file_production"
# echo "Production dump done"

# echo "Executing Staging dump..."
# mysql -uxfera -pxfera xfera_mock < "$db_assets_path$db_dump_file_staging"
# echo "Staging dump done"

#bundle exec rake db:fixtures:load \
#  && bundle exec rake db:fixtures:load RAILS_ENV=test


# mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera.* TO 'xfera'@'%';"
# mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_test.* TO 'xfera'@'%';"
# mysql -uroot -proot --execute "GRANT ALL PRIVILEGES ON xfera_mock.* TO 'xfera'@'%';"
# mysql -uroot -proot --execute "FLUSH PRIVILEGES;"

# Remove db structure
# drop database xfera; drop database xfera_test; drop database xfera_mock;
# select User from mysql.user; drop user xfera; drop user xfera@localhost;
