#FROM nextcloud:14.0.4-apache
FROM nextcloud:15.0.0-apache

COPY redis.config.php /usr/src/nextcloud/config/redis.config.php
RUN apt-get update && apt-get install -y \
  sudo \
  apt-utils \
  whiptail \
  iproute2 \
  lsb-core \
  lshw \
  wget \
  docker





