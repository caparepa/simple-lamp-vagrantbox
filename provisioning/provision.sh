#!/bin/bash

echo "Provisioning virtual machine..."

# Git
echo "Installing Git..."
sudo apt-get install git -y > /dev/null

# Apache
echo "Installing Apache..."
sudo apt-get install apache2 libapache2-mod-fastcgi apache2-mpm-worker -y > /dev/null

# Add ServerName to httpd.conf
echo "ServerName localhost" > /etc/apache2/httpd.conf

# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/public"
  ServerName localhost
  <Directory "/var/www/public">
    AllowOverride All
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf

# Loading needed modules to make apache work
a2enmod actions fastcgi rewrite
service apache2 restart

# Standard update
echo "Standard update..."
sudo apt-get update
sudo apt-get upgrade

# PHP
echo "Updating PHP repository..."
sudo apt-get install python-software-properties build-essential -y > /dev/null
sudo add-apt-repository ppa:ondrej/php -y > /dev/null
sudo apt-get update

echo "Installing PHP..."
sudo apt-get install php7.1 php7.1-common php7.1-cli -y > /dev/null

echo "Installing PHP extensions..."
sudo apt-get install libapache2-mod-php7.1 php7.1-mbstring php7.1-gd php7.1-intl php7.1-xml php7.1-mysql php7.1-mcrypt php7.1-zip -y > /dev/null

# Reload Apache
sudo service apache2 reload

# MySQL 
echo "Preparing MySQL..."
sudo apt-get install debconf-utils -y > /dev/null
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"

echo "Installing MySQL..."
sudo apt-get install mysql-server -y > /dev/null

# Nginx Configuration
echo "Bypassing Nginx installation..."
#echo "Configuring Nginx"
#cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
#ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/

#rm -rf /etc/nginx/sites-available/default

# Restart Nginx for the config to take effect
#service nginx restart > /dev/null

# Adding NodeJS from Nodesource. This will Install NodeJS Version 5 and npm
echo "Installing NodeJS..."
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs > /dev/null

# Installing Bower and Gulp
echo "Installing Bower and Gulp..."
sudo npm install -g bower gulp > /dev/null

# Installing GIT
echo "Installing Git..."
sudo apt-get install -y git > /dev/null

# Install Composer
echo "Installing Composer..."
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer > /dev/null

echo "Finished provisioning."