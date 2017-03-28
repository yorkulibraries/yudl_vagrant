#!/bin/bash

echo "Installing warctools."

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1090
  . "$SHARED_DIR"/configs/variables
fi

# Set apt-get for non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# Dependencies
apt-get install python-setuptools python-unittest2 -y -qq

# Clone and build warctools
cd /tmp || exit
git clone https://github.com/internetarchive/warctools.git
cd warctools && ./setup.py build && ./setup.py install
