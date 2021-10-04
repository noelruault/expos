# Base image
## https://hub.docker.com/_/ruby/
FROM ruby:2.3.1

MAINTAINER Noel Ruault <noel.ruault@qvantel.com>

# Mariadb/mysql-server dependent
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Install apt based dependencies required to run Rails as
# well as RubyGems. As the Ruby image itself is based on a
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev nodejs \
    git \
    curl libcurl3\
    nano less sed \
    gettext  \
    redis-server \
    libxml2 \
    libssl-dev \
    libreadline-dev \
    zlib1g zlib1g-dev \
    mysql-server
    # mariadb-server libmariadb-client-lgpl-dev libmariadb-client-lgpl-dev-compat \
    # mariadb-server/mysql-server # TODO: Dockerize mariadb


# Configure the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT
# commands.
RUN mkdir -p /mnt
WORKDIR /mnt

ENV BUNDLE_PATH /box
# ADD . /mnt/

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
# COPY Gemfile Gemfile.lock ./
# RUN gem install bundler && bundle install --jobs 20 --retry 5
# To run all bundle install at once.
#RUN find -name Gemfile -execdir bundle install \;
#CMD find -name Gemfile -execdir bundle install \;

# Create the database
COPY docker/scripts/create_db.sh /mnt/docker/scripts/create_db.sh
RUN service mysql start && sh /mnt/docker/scripts/create_db.sh

# Dump the database
COPY docker/scripts/db/database_dump.sql /mnt/docker/scripts/db/database_dump.sql
# RUN service mysql start &&  mysql -uroot -proot -D xfera < /mnt/docker/scripts/db/database_dump.sql

# FIX 'Failed to open TCP connection to localhost:35729' error
# https://github.com/locomotivecms/wagon/issues/340
COPY /etc/hosts /etc/hosts.new \
RUN sed -i 's/::1\tlocalhost ip6-localhost ip6-loopback/::1 ip6-localhost ip6-loopback/' /etc/hosts.new \
COPY -f /etc/hosts.new /etc/hosts

COPY docker/scripts/db/mariadb.cnf /etc/mysql/
COPY docker/scripts/db/mariadb.conf.d/50-mysqld_safe.cnf /etc/mysql/mariadb.conf.d/
COPY docker/scripts/db/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/

RUN find -name Gemfile -execdir gem install bundler \;

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
# EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
# CMD cd newton && bundle install && rails s -b 0.0.0.0

# docker build -t qvantel/masmovil-base .
# docker run -d -it -v $(pwd):/mnt --rm -p 3000:3000 --name=qv-masmovil qvantel/masmovil-base
# docker exec -it qv-masmovil bash

# docker build -t qvantel/masmovil-base ./docker
# docker run -d -it --rm --name=qv-masmovil qvantel/masmovil-base bash
# docker exec -it qv-masmovil bash

# rails s -b 0.0.0.0
