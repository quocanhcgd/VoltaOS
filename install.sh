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

export LC_ALL=C

# Update OS
apt-get update
apt-get -y upgrade
apt install -y openssh-server net-tools nginx git apt-transport-https lsb-release zip curl dirmngr sudo