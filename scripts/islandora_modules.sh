#!/bin/bash

echo "Installing all Islandora Foundation modules"

SHARED_DIR=$1

if [ -f "$SHARED_DIR/configs/variables" ]; then
  . "$SHARED_DIR"/configs/variables
fi

cd "$HOME"
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
# shellcheck disable=SC2016
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> .bashrc
sudo chown -hR ubuntu:ubuntu .config .drush

# Permissions and ownership
sudo chown -hR ubuntu:www-data "$DRUPAL_HOME"/sites/all/themes
sudo chown -hR ubuntu:www-data "$DRUPAL_HOME"/sites/all/libraries
sudo chown -hR ubuntu:www-data "$DRUPAL_HOME"/sites/all/modules
sudo chown -hR ubuntu:www-data "$DRUPAL_HOME"/sites/default/files
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/themes
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/libraries
sudo chmod -R 755 "$DRUPAL_HOME"/sites/all/modules
sudo chmod -R 755 "$DRUPAL_HOME"/sites/default/files

# Clone all Islandora Foundation modules
cd "$DRUPAL_HOME"/sites/all/modules || exit
while read -r LINE; do
  git clone https://github.com/Islandora/"$LINE"
done < "$SHARED_DIR"/configs/islandora-module-list-sans-tuque.txt

# Set git filemode false for git
cd "$DRUPAL_HOME"/sites/all/modules || exit
while read -r LINE; do
  cd "$LINE" || exit
  git config core.filemode false
  cd "$DRUPAL_HOME"/sites/all/modules || exit
done < "$SHARED_DIR"/configs/islandora-module-list-sans-tuque.txt

# Clone Tuque
cd "$DRUPAL_HOME"/sites/all || exit
if [ ! -d libraries ]; then
  mkdir libraries
fi
cd "$DRUPAL_HOME"/sites/all/libraries || exit
git clone https://github.com/Islandora/tuque.git

cd "$DRUPAL_HOME"/sites/all/libraries/tuque || exit
git config core.filemode false

# Check for a user's .drush folder, create if it doesn't exist
if [ ! -d "$HOME_DIR/.drush" ]; then
  mkdir "$HOME_DIR/.drush"
  sudo chown ubuntu:ubuntu "$HOME_DIR"/.drush
fi

# Move OpenSeadragon drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" ] && [ -f "$DRUPAL_HOME/sites/all/modules/islandora_openseadragon/islandora_openseadragon.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_openseadragon/islandora_openseadragon.drush.inc" "$HOME_DIR/.drush"
fi

# Move video.js drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" ] && [ -f "$DRUPAL_HOME/sites/all/modules/islandora_videojs/islandora_videojs.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_videojs/islandora_videojs.drush.inc" "$HOME_DIR/.drush"
fi

# Move pdf.js drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" ] && [ -f "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_pdfjs/islandora_pdfjs.drush.inc" "$HOME_DIR/.drush"
fi

# Move IA Bookreader drush file to user's .drush folder
if [ -d "$HOME_DIR/.drush" ] && [ -f "$DRUPAL_HOME/sites/all/modules/islandora_internet_archive_bookreader/islandora_internet_archive_bookreader.drush.inc" ]; then
  mv "$DRUPAL_HOME/sites/all/modules/islandora_internet_archive_bookreader/islandora_internet_archive_bookreader.drush.inc" "$HOME_DIR/.drush"
fi

# Pre-configure islandora
drush eval "variable_set('islandora_base_url', 'http://10.0.0.124:8080/fedora')"
drush eval "variable_set('islandora_repository_pid', 'yul:yul')"
drush eval "variable_set('islandora_use_datastream_cache_headers', FALSE)"
drush eval "variable_set('islandora_defer_derivatives_on_ingest', FALSE)"
drush eval "variable_set('islandora_show_print_option', FALSE)"
drush eval "variable_set('islandora_render_drupal_breadcrumbs', TRUE)"
drush eval "variable_set('islandora_namespace_restriction_enforced', TRUE)"
drush eval "variable_set('islandora_pids_allowed', 'yul: islandora:')"
drush eval "variable_set('islandora_require_obj_upload', FALSE)"
drush eval "variable_set('islandora_breadcrumbs_backends', TRUE)"
drush eval "variable_set('islandora_render_context_ingeststep', FALSE)"
drush eval "variable_set('islandora_use_object_semaphores', FALSE)"
drush eval "variable_set('islandora_risearch_use_itql_when_necessary', FALSE)"

# Islandora Solr Search configuration
drush eval "variable_set('islandora_solr_url', 'iota.library.yorku.ca:8080/solr')"


# TODO djatoka

drush -y -u 1 en php_lib islandora objective_forms
drush -y -u 1 en islandora_solr islandora_solr_metadata islandora_solr_facet_pages islandora_solr_views
drush -y -u 1 en islandora_basic_collection islandora_pdf islandora_audio islandora_book islandora_compound_object islandora_disk_image islandora_basic_image islandora_large_image islandora_newspaper islandora_video islandora_web_archive
drush -y -u 1 en islandora_premis islandora_checksum islandora_checksum_checker
drush -y -u 1 en islandora_book_batch islandora_pathauto islandora_pdfjs islandora_videojs
drush -y -u 1 en xml_forms xml_form_builder xml_schema_api xml_form_elements xml_form_api jquery_update zip_importer islandora_basic_image islandora_compound_object islandora_solr_config
drush -y -u 1 en islandora_fits islandora_ocr islandora_oai islandora_marcxml islandora_xacml_api islandora_xacml_editor islandora_xmlsitemap colorbox islandora_internet_archive_bookreader islandora_batch_report islandora_newspaper_batch 

cd "$DRUPAL_HOME"/sites/all/modules || exit

# Set variables for Islandora modules
drush eval "variable_set('islandora_audio_viewers', array('name' => array('none' => 'none', 'islandora_videojs' => 'islandora_videojs'), 'default' => 'islandora_videojs'))"
drush eval "variable_set('islandora_fits_executable_path', '$FITS_HOME/fits-$FITS_VERSION/fits.sh')"
drush eval "variable_set('islandora_fits_techmd_dsid', 'TECHMD_FITS')"
drush eval "variable_set('islandora_lame_url', '/usr/bin/lame')"
drush eval "variable_set('islandora_video_viewers', array('name' => array('none' => 'none', 'islandora_videojs' => 'islandora_videojs'), 'default' => 'islandora_videojs'))"
drush eval "variable_set('islandora_video_ffmpeg_path', '/usr/local/bin/ffmpeg')"
drush eval "variable_set('islandora_book_viewers', array('name' => array('none' => 'none', 'islandora_internet_archive_bookreader' => 'islandora_internet_archive_bookreader'), 'default' => 'islandora_internet_archive_bookreader'))"
drush eval "variable_set('islandora_book_page_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_large_image_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_use_kakadu', TRUE)"
drush eval "variable_set('islandora_newspaper_issue_viewers', array('name' => array('none' => 'none', 'islandora_internet_archive_bookreader' => 'islandora_internet_archive_bookreader'), 'default' => 'islandora_internet_archive_bookreader'))"
drush eval "variable_set('islandora_newspaper_page_viewers', array('name' => array('none' => 'none', 'islandora_openseadragon' => 'islandora_openseadragon'), 'default' => 'islandora_openseadragon'))"
drush eval "variable_set('islandora_pdf_create_fulltext', 1)"
drush eval "variable_set('islandora_checksum_enable_checksum', TRUE)"
drush eval "variable_set('islandora_checksum_checksum_type', 'SHA-1')"
drush eval "variable_set('islandora_ocr_tesseract', '/usr/bin/tesseract')"
drush eval "variable_set('islandora_batch_java', '/usr/bin/java')"
drush eval "variable_set('image_toolkit', 'imagemagick')"
drush eval "variable_set('imagemagick_convert', '/usr/bin/convert')"

# TODO checksum checker
# Drupal Cron
# 25
# OBJ
# dlibrary@yorku.ca
# Send verification cycle completion notice TRUE
# Log checksum mismatches TRUE


