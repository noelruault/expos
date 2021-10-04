#!/bin/bash

VAGRANT_MARIADB_CONFIG_ROUTE='/etc/mysql/'
BACKUP_MARIADB_CONFIG_ROUTE='/home/nruault/Projects/masmovil-dockerize/docker/scripts/db'
EXPORT_OFFERS_QUERY="Offer.where(\"valid_to < '2017-07-01'\").delete_all;OfferItem.where(\"valid_to < '2017-07-01'\").delete_all;OfferCriterion.where(\"valid_to < '2017-07-01'\").delete_all;Offer.export_all_to_redis"

echo "\033[32mSetting up MariaDB...\033[32m"
{
  docker container exec -it $app_name sh -c "cp ${BACKUP_MARIADB_CONFIG_ROUTE}/mariadb.cnf $VAGRANT_MARIADB_CONFIG_ROUTE" && \
  docker container exec -it $app_name sh -c "cp ${BACKUP_MARIADB_CONFIG_ROUTE}/mariadb.conf.d/50-mysqld_safe.cnf ${VAGRANT_MARIADB_CONFIG_ROUTE}mariadb.conf.d/" && \
  docker container exec -it $app_name sh -c "cp ${BACKUP_MARIADB_CONFIG_ROUTE}/mariadb.conf.d/50-server.cnf ${VAGRANT_MARIADB_CONFIG_ROUTE}mariadb.conf.d/"
} || {
  echo "\033[31mERROR copying mariadb config files\033[31m"
  exit 1
}

vagrant reload
{
  docker container exec -it $app_name sh -c "mysql --execute=\"CREATE USER 'xfera'@'localhost' IDENTIFIED BY 'xfera';\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"CREATE DATABASE xfera CHARACTER SET utf8;\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"CREATE DATABASE xfera_test CHARACTER SET utf8;\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"CREATE DATABASE xfera_mock CHARACTER SET utf8;\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"grant all privileges on xfera.* to 'xfera'@'localhost' with grant option;\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"grant all privileges on xfera_test.* to 'xfera'@'localhost' with grant option;\"" && \
  docker container exec -it $app_name sh -c "mysql --execute=\"grant all privileges on xfera_mock.* to 'xfera'@'localhost' with grant option;\""
} || {
  echo "\033[31mERROR RUNNING MySql commands creating users and databases\033[31m"
  exit 1
}

echo "\033[32mInstalling RVM...\033[32m"
{
  docker container exec -it $app_name sh -c 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB' && \
  docker container exec -it $app_name sh -c '\curl -sSL https://get.rvm.io | bash -s stable' && \
  docker container exec -it $app_name sh -c 'source /home/vagrant/.rvm/scripts/rvm' && \
  vagrant reload
} || {
  echo "\033[31mERROR INSTALLING RVM\033[31m"
  exit 1
}

{
  echo "\033[32mInstalling Ruby...\033[32m" && \
  docker container exec -it $app_name sh -c 'rvm install 2.3.1 && rvm use 2.3.1 --default && gem install bundler && rvm reinstall 2.3.1' && \
  echo "\033[32mInstalling gems...\033[32m" && \
  docker container exec -it $app_name sh -c 'cd /vagrant && find -name Gemfile -execdir bundle install \;'
} || {
  echo "\033[31mERROR INSTALLING RUBY AND GEMS\033[31m"
  exit 1
}

{
  echo "\033[32mSetting up database...\033[32m" && \
  docker container exec -it $app_name sh -c 'cd /vagrant/$app_name/ && bundle exec rake db:create && bundle exec rake db:permissions:recreate && bundle exec rake db:permissions:create_acgp_fixtures' && \
  docker container exec -it $app_name sh -c 'mysql -uxfera -pxfera xfera < /vagrant/mariadb_config_files/offers_terminals_categories_production.sql' && \
  docker container exec -it $app_name sh -c 'mysql -uxfera -pxfera xfera_mock < /vagrant/mariadb_config_files/offers_terminals_categories_staging.sql' && \
  docker container exec -it $app_name sh -c 'cd /vagrant/$app_name/ && bundle exec rake db:fixtures:load && bundle exec rake db:fixtures:load RAILS_ENV=test'
} || {
  echo "\033[31mERROR SETTING UP AND COPYING DATABASE DUMP\033[31m"
  exit 1
}

vagrant halt && vagrant box update && vagrant up && docker container exec -it $app_name sh -c 'apt-get update' && docker container exec -it $app_name sh -c 'apt-get upgrade -y' && vagrant reload

echo "\033[32mExporting offers to REDIS...\033[32m"
{
  docker container exec -it $app_name sh -c "cd /vagrant/$app_name && bundle exec rails runner '$EXPORT_OFFERS_QUERY'"
} || {
  echo "\033[31mERROR EXPORTING OFFERS TO REDIS\033[31m"
  exit 1
}
echo "\033[32mENVIRONMENT CREATED AND RUNNING\033[32m"
