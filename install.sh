#!/usr/bin/env bash
# This file is part of the Volta Project.
#
# Copyright (c) 2018 - 2019 AzuyaLabs
#
# License AGPL-3.0
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
# @author Sacha Telgenhof <me at sachatelgenhof dot com>

# Volta installation script
# Shell script that prepares your OS and installs the Volta application.

# Source error handling, leave this in place
set -x
set -e

VOLTA_OS_USER=volta
VOLTA_OS_USER_PASSWORD=volta
VOLTA_HTTPD_BASE_DIR=/var/www/volta
VOLTA_HTTPD_DOCUMENT_ROOT=/var/www/volta/public
VOLTA_APP_REPO=https://github.com/azuyalabs/Volta.git
VOLTA_APP_REPO_BRANCH=develop

export LC_ALL=C.UTF-8

# Update OS
apt-get update
apt-get -y upgrade
apt install -y openssh-server net-tools nginx git apt-transport-https lsb-release zip curl dirmngr sudo

# Configuration
useradd -m -p $(openssl passwd -1 ${PASSWORD}) -s /bin/bash -G sudo ${VOLTA_OS_USER}
usermod -aG www-data $VOLTA_OS_USER
usermod -aG sudo $VOLTA_OS_USER

# Install PHP (and related)
apt-get install software-properties-common
LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y php7.3-cli php7.3-fpm php7.3-intl php7.3-json php7.3-mbstring php7.3-xml php7.3-curl php7.3-bcmath php7.3-zip php7.3-sqlite

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install and configure Volta
echo "--- Installing Volta"
git clone -b $VOLTA_APP_REPO_BRANCH $VOLTA_APP_REPO $VOLTA_HTTPD_BASE_DIR

find "$VOLTA_HTTPD_BASE_DIR" -type d -exec chmod 2775 {} \;
find "$VOLTA_HTTPD_BASE_DIR" -type f -exec chmod 0664 {} \;

pushd $VOLTA_HTTPD_BASE_DIR
    composer install
    cp .env.example .env

    php artisan key:generate
    php artisan passport:key
    php artisan migrate
popd

usermod -aG www-data $VOLTA_OS_USER
chown -R www-data:www-data "$VOLTA_HTTPD_BASE_DIR"

# Activate Volta on Nginx
cp -v -r --preserve=mode,timestamps ./filesystem/root/. /

NGINX_DEFAULT_CONFIG="/etc/nginx/sites-enabled/default"
if [ -f $NGINX_DEFAULT_CONFIG ]; then
    rm $NGINX_DEFAULT_CONFIG
fi

ln -sf /etc/nginx/sites-available/volta /etc/nginx/sites-enabled/

# Cleanup
apt-get clean
apt-get autoremove -y

# Restart services
systemctl restart php-fpm
systemctl restart nginx