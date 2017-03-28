#!/bin/sh

echo "Installing LAMP server packages"

apt-get -qq install -y libwrap0 ssl-cert libterm-readkey-perl mysql-client libdbi-perl libmysqlclient20 mysql-client-core-5.7 mysql-common apache2 mysql-server mysql-server-core-5.7 tcpd libaio1 mysql-server libdbd-mysql-perl libhtml-template-perl php7.0 php7.0-dev libapache2-mod-php7.0 php7.0-mbstring imagemagick lame libimage-exiftool-perl bibutils poppler-utils php7.0-mysql php7.0-gd php7.0-curl php7.0-soap php7.0-xml php-imagick

usermod -a -G www-data ubuntu

# shellcheck disable=SC2154
sed -i '$idate.timezone=America/Toronto' /etc/php/7.0/cli/php.ini
