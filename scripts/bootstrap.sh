#!/bin/bash

SHARED_DIR=$1
if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1091
  . "$SHARED_DIR"/configs/variables
fi

if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p "$DOWNLOAD_DIR"
fi

#######################################################################
# Work around for https://bugs.launchpad.net/cloud-images/+bug/1569237
echo "ubuntu:ubuntu" | chpasswd
#######################################################################

cp /vagrant/configs/motd /etc/motd

# Set apt-get for non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Update
apt-get -y -qq update && apt-get -y -qq upgrade

# SSH
apt-get -y -qq install openssh-server

# Build tools
apt-get -y -qq install build-essential automake libtool

# Git vim
apt-get -y -qq install git vim

# Java (Oracle)
apt-get install -y software-properties-common
apt-get install -y python-software-properties
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get install -y oracle-java8-installer
update-java-alternatives -s java-8-oracle
apt-get install -y oracle-java8-set-default

# Set JAVA_HOME variable both now and for when the system restarts
export JAVA_HOME
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment

# Maven
apt-get -y install maven

# Wget and curl
apt-get -y -qq install wget curl

# Postfix
apt-get -y -qq install postfix

# Bug fix for Ubuntu 14.04 with zsh 5.0.2 -- https://bugs.launchpad.net/ubuntu/+source/zsh/+bug/1242108
export MAN_FILES
MAN_FILES=$(wget -qO- "http://sourceforge.net/projects/zsh/files/zsh/5.0.2/zsh-5.0.2.tar.gz/download" \
  | tar xvz -C /usr/share/man/man1/ --wildcards "zsh-5.0.2/Doc/*.1" --strip-components=2)
for MAN_FILE in $MAN_FILES; do gzip /usr/share/man/man1/"${MAN_FILE##*/}"; done

# More helpful packages
apt-get -y install htop tree zsh unzip

# Set some params so it's non-interactive for the lamp-server install
debconf-set-selections <<< 'mysql-server mysql-server/root_password password islandora'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password islandora'
debconf-set-selections <<< "postfix postfix/mailname string dev-digital.library.yorku.ca"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Add web group, and put some users in it
groupadd web
usermod -a -G web www-data
usermod -a -G web ubuntu
