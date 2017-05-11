#!/bin/bash

echo "Installing Drupal."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1090
  . "$SHARED_DIR"/configs/variables
fi

# Set apt-get for non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Apache configuration file
export APACHE_CONFIG_FILE=/etc/apache2/sites-enabled/000-default.conf

# Composer
cd /tmp
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-progress
mv composer.phar /usr/local/bin/composer

# Drush and drupal deps
cd "$HOME"
# shellcheck disable=SC2016
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> .bashrc
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> /home/ubuntu/.bashrc
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
composer global require drush/drush
cd /root
cp -R .config /home/ubuntu
cp -R .drush /home/ubuntu

# Upload Progress
cd /tmp
git clone https://github.com/php/pecl-php-uploadprogress.git
cd pecl-php-uploadprogress
phpize
./configure --enable-uploadprogress
make && make install

#Enable rewrite
a2enmod rewrite
service apache2 reload
cd /var/www || exit

# Download Drupal
drush dl drupal-7.x --drupal-project-rename=yudl
mkdir /opt/drupal_private
cd /var/www/yudl/sites/default
cp default.settings.php settings.php
sed -i "s#$databases = array();#$databases = array (\n  'default' => \n  array (\n    'default' => \n    array (\n      'database' => 'dev_yudl',\n      'username' => 'dev_yudl',\n      'password' => 'islandora',\n      'host' => '10.0.0.14',\n      'port' => '',\n      'driver' => 'mysql',\n      'prefix' => '',\n    ),\n  ),\n);#" settings.php
chmod 444 settings.php

# Permissions
chown -R www-data:www-data /var/www/yudl /opt/drupal_private
chmod -R g+w /var/www/yudl

# Enable proxy module
ln -s /etc/apache2/mods-available/proxy.load /etc/apache2/mods-enabled/proxy.load
ln -s /etc/apache2/mods-available/proxy_http.load /etc/apache2/mods-enabled/proxy_http.load
ln -s /etc/apache2/mods-available/proxy_html.load /etc/apache2/mods-enabled/proxy_html.load
ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load

# Set document root
sed -i "s|DocumentRoot /var/www/html$|DocumentRoot $DRUPAL_HOME|" $APACHE_CONFIG_FILE

# Set override for drupal directory
# Now inserting into VirtualHost container - whikloj (2015-04-30)
if [ "$(grep -c "ProxyPass" $APACHE_CONFIG_FILE)" -eq 0 ]; then

sed -i 's#<VirtualHost \*:80>#<VirtualHost \*:8000>#' $APACHE_CONFIG_FILE

sed -i 's/Listen 80/Listen \*:8000/' /etc/apache2/ports.conf

sed -i "/Listen \*:8000/a \
NameVirtualHost \*:8000" /etc/apache2/ports.conf

# shellcheck disable=SC2162
read -d '' APACHE_CONFIG << APACHE_CONFIG_TEXT
	ServerAlias yudl-vagrant

	<Directory ${DRUPAL_HOME}>
		Options Indexes FollowSymLinks
		AllowOverride All
		Require all granted
	</Directory>

	ProxyRequests Off
	ProxyPreserveHost On

	<Proxy *>
		Order deny,allow
		Allow from all
	</Proxy>
APACHE_CONFIG_TEXT

sed -i "/<\/VirtualHost>/i $(echo "|	$APACHE_CONFIG" | tr '\n' '|')" $APACHE_CONFIG_FILE
tr '|' '\n' < $APACHE_CONFIG_FILE > $APACHE_CONFIG_FILE.t 2> /dev/null; mv $APACHE_CONFIG_FILE{.t,}

fi

# Torch the default index.html
rm -rf /var/www/html

# Cycle apache
service apache2 restart

# Make the modules directory
cd /var/www/yudl
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules || exit

wget http://10.0.0.14/yudl_modules.tar.gz
tar -xzvf yudl_modules.tar.gz
rm yudl_modules.tar.gz


cd "$DRUPAL_HOME"/sites/all/libraries || exit
wget http://10.0.0.14/yudl_libraries.tar.gz
tar -xzvf yudl_libraries.tar.gz
rm yudl_libraries.tar.gz

cd "$DRUPAL_HOME"/sites/all/themes || exit
wget http://10.0.0.14/yudl_themes.tar.gz
tar -xzvf yudl_themes.tar.gz
rm yudl_themes.tar.gz

chown -hR www-data:www-data "$DRUPAL_HOME"/sites/all/libraries
chown -hR www-data:www-data "$DRUPAL_HOME"/sites/all/modules
chown -hR www-data:www-data "$DRUPAL_HOME"/sites/all/themes
cd "$DRUPAL_HOME"/sites/all/modules

drush dis drush dis memcache
drush eval "variable_set('islandora_solr_url', '10.0.0.39:8080/solr/yudl')"  

# York logo
cd "$DRUPAL_HOME"/sites/deftault/files
wget https://digital.library.yorku.ca/sites/default/files/yorklogo-small.png

drush cc all

drush dl coder
drush -y en coder
chown -hR www-data:www-data "$DRUPAL_HOME"/sites/all/modules

# php.ini templating
#cp -v "$SHARED_DIR"/configs/php.ini /etc/php5/apache2/php.ini

service apache2 restart

# sites/default/files ownership
cd "$DRUPAL_HOME"/sites/default || exit
if [ ! -d files ]; then
  mkdir files
fi
chown -hR www-data:www-data files
