#!/bin/bash

SHARED_DIR=$1
if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1091
  . "$SHARED_DIR"/configs/variables
fi

# Set correct permissions on sites/default/files
chmod -R 774 /var/www/yudl/sites/default/files

export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# Allow anonymous & authenticated users to view repository objects
drush --root=/var/www/yudl role-add-perm "anonymous user" "view fedora repository objects"
drush --root=/var/www/yudl role-add-perm "authenticated user" "view fedora repository objects"
drush --root=/var/www/yudl cc all
