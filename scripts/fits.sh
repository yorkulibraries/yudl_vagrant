#!/bin/bash

echo "Installing FITS"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1090
  . "$SHARED_DIR"/configs/variables
fi

# Setup FITS_HOME
if [ ! -d "$FITS_HOME" ]; then
  mkdir "$FITS_HOME"
fi
chown ubuntu:ubuntu "$FITS_HOME"

# Download and deploy FITS
if [ ! -f "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" ]; then
  wget -q -O "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" "http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip"
fi

unzip "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" -d "$FITS_HOME"
cd "$FITS_HOME/fits-$FITS_VERSION" || exit
chmod +x fits.sh
chmod +x fits-env.sh
