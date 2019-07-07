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

VOLTA_OS_USER=root # This should be a different user
VOLTA_HTTPD_BASE_DIR=/var/www/volta
VOLTA_HTTPD_DOCUMENT_ROOT=/var/www/volta/public
VOLTA_APP_REPO=https://github.com/azuyalabs/Volta.git
VOLTA_APP_REPO_BRANCH=develop

export LC_ALL=C

# Update OS
apt-get update
apt-get -y upgrade
apt install -y openssh-server net-tools nginx git apt-transport-https lsb-release zip curl dirmngr sudo

# Configuration
usermod -aG www-data $VOLTA_OS_USER
usermod -aG sudo $VOLTA_OS_USER

# Install PHP (and related)
apt-get install software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install -y php7.3-cli php7.3-fpm php7.3-intl php7.3-json php7.3-mbstring php7.3-xml php7.3-curl php7.3-bcmath php7.3-zip php7.3-sqlite

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Install and configure Volta
echo "--- Installing Volta"
git clone -u pi -b $VOLTA_APP_REPO_BRANCH $VOLTA_APP_REPO $VOLTA_HTTPD_BASE_DIR

find "$VOLTA_HTTPD_BASE_DIR" -type d -exec chmod 2775 {} \;
find "$VOLTA_HTTPD_BASE_DIR" -type f -exec chmod 0664 {} \;
