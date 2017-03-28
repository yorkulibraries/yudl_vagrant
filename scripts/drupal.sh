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

# Permissions
chown -R www-data:www-data yudl
chmod -R g+w yudl

# Do the install
cd yudl || exit
drush si -y --db-url=mysql://root:islandora@localhost/drupal7 --site-name=yudl-development.org
drush user-password admin --password=islandora

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

	ProxyPass /fedora/get http://localhost:8080/fedora/get
	ProxyPassReverse /fedora/get http://localhost:8080/fedora/get
	ProxyPass /fedora/services http://localhost:8080/fedora/services
	ProxyPassReverse /fedora/services http://localhost:8080/fedora/services
	ProxyPass /fedora/describe http://localhost:8080/fedora/describe
	ProxyPassReverse /fedora/describe http://localhost:8080/fedora/describe
	ProxyPass /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPassReverse /fedora/risearch http://localhost:8080/fedora/risearch
	ProxyPass /adore-djatoka http://localhost:8080/adore-djatoka
	ProxyPassReverse /adore-djatoka http://localhost:8080/adore-djatoka
APACHE_CONFIG_TEXT

sed -i "/<\/VirtualHost>/i $(echo "|	$APACHE_CONFIG" | tr '\n' '|')" $APACHE_CONFIG_FILE
tr '|' '\n' < $APACHE_CONFIG_FILE > $APACHE_CONFIG_FILE.t 2> /dev/null; mv $APACHE_CONFIG_FILE{.t,}

fi

# Torch the default index.html
rm -rf /var/www/html

# Cycle apache
service apache2 restart

# Make the modules directory
if [ ! -d sites/all/modules ]; then
  mkdir -p sites/all/modules
fi
cd sites/all/modules || exit

# Modules
drush dl devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker date
drush -y en devel imagemagick ctools jquery_update pathauto xmlsitemap views variable token libraries datepicker_views

drush dl coder
drush -y en coder

drush dl advanced_help chart chosen cron_debug devel entity features fontawesome geofield google_analytics i18n icon imagemagick leaflet markdown memcache metatag mollom nagios pathauto plupload redirect remove_generator schemaorg smart_ip smtp subpathauto superfish tabtamer token uofm_maintenance_scripts variable views views_bootstrap views_infinite_scroll views_slideshow webform xmlsitemap

drush -y en advanced_help chart chosen cron_debug devel entity features fontawesome geofield i18n icon imagemagick leaflet markdown memcache metatag mollom nagios pathauto plupload redirect remove_generator schemaorg smart_ip smtp subpathauto superfish tabtamer token uofm_maintenance_scripts variable views views_bootstrap views_infinite_scroll views_slideshow webform xmlsitemap

# php.ini templating
#cp -v "$SHARED_DIR"/configs/php.ini /etc/php5/apache2/php.ini

service apache2 restart

# sites/default/files ownership
cd "$DRUPAL_HOME"/sites/default || exit
if [ ! -d files ]; then
  mkdir files
fi
chown -hR www-data:www-data files

# Run cron
cd "$DRUPAL_HOME"/sites/all/modules || exit
drush cron
