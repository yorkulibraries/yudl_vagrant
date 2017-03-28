#!/bin/bash

SHARED_DIR=$1
if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1091
  . "$SHARED_DIR"/configs/variables
fi

echo "Installing Djatoka"

# Setup install path and download Djatoka
if [ ! -d "$DJATOKA_HOME" ]; then
  mkdir "$DJATOKA_HOME"
fi

if [ ! -f "$DOWNLOAD_DIR/adore-djatoka.tar.gz" ]; then
  echo "Downloading Adore-Djatoka"
  wget -q -O "$DOWNLOAD_DIR/adore-djatoka.tar.gz" "http://downloads.sourceforge.net/project/djatoka/djatoka/1.1/adore-djatoka-1.1.tar.gz"
fi

cd /tmp || exit
cp "$DOWNLOAD_DIR/adore-djatoka.tar.gz" /tmp
tar -xzvf adore-djatoka.tar.gz
cd adore-djatoka-1.1 || exit
mv -v ./* "$DJATOKA_HOME"

# Symlink kdu_compress for Large Image Solution Pack
ln -s "$DJATOKA_HOME"/bin/Linux-x86-64/kdu_compress /usr/bin/kdu_compress

# Libraries
cp "$SHARED_DIR"/configs/kdu_libs.conf /etc/ld.so.conf.d/kdu_libs.conf
