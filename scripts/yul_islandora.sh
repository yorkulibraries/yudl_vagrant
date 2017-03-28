#!/bin/bash

echo "Installing additional YUL Islandora customizations"

SHARED_DIR=$1
if [ -f "$SHARED_DIR/configs/variables" ]; then
  # shellcheck disable=SC1091
  . "$SHARED_DIR"/configs/variables
fi

export PATH="$PATH:$HOME/.config/composer/vendor/bin"
cd "$DRUPAL_HOME"/sites/all/modules

cd islandora_solution_pack_video
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_video.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_collection
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_collection.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_audio
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_audio.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_large_image
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_large_image.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_pdf
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_pdf.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_book
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_book.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solution_pack_web_archive
git remote add yul https://github.com/yorkulibraries/islandora_solution_pack_web_archive.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solr_search
git remote add yul https://github.com/yorkulibraries/islandora_solr_search.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora
git remote add yul https://github.com/yorkulibraries/islandora.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_xml_forms
git remote add yul https://github.com/yorkulibraries/islandora_xml_forms.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_solr_metadata
git remote add yul https://github.com/yorkulibraries/islandora_solr_metadata.git
git fetch --all
git pull yul 7.x
cd ..

cd islandora_openseadragon
git remote add yul https://github.com/yorkulibraries/islandora_openseadragon.git
git fetch --all
git pull yul 7.x
cd ..

cd "$DRUPAL_HOME"/sites/all/libraries/tuque
git remote add yul https://github.com/yorkulibraries/tuque.git
cd fetch --all
git pull yul 1.x
cd "$DRUPAL_HOME"/sites/all/modules

# Additional modules
git clone -b 7.x-yul https://github.com/yorkulibraries/islandora_blocks.git
cd islandora_blocks 
git config core.filemode false
cd ..

git clone https://github.com/yorkulibraries/islandora_datastream_editor.git
cd islandora_datastream_editor
git config core.filemode false
cd ..

git clone https://github.com/yorkulibraries/islandora_transcript.git
cd islandora_transcript
git config core.filemode false
cd ..

git clone https://github.com/yorkulibraries/uofm_maintenance_scripts.git
cd uofm_maintenance_scripts
git config core.filemode false
cd ..

git clone https://github.com/mjordan/islandora_simple_map.git
cd islandora_simple_map
git config core.filemode false
cd ..

git clone https://github.com/discoverygarden/islandora_plupload.git
cd islandora_plupload
git config core.filemode false
cd ..

drush cc all
drush pm-en islandora_block islandora_datastream_editor islandora_transcript uofm_maintenance_scripts islandora_simple_map islandora_plupload

# York logo
cd "$DRUPAL_HOME"/sites/deftault/files
wget https://digital.library.yorku.ca/sites/default/files/yorklogo-small.png

# Setup and configure Bootstrap theme
cd "$DRUPAL_HOME"/sites/all/themes
git clone https://github.com/yorkulibraries/bootstrap.git
drush en -y bootstrap
drush vset theme_default bootstrap
drush ev 'variable_set("theme_bootstrap_settings", array("toggle_logo" => "0", "toggle_name" => "0", "toggle_slogan" => "1", "toggle_node_user_picture" => "1", "toggle_comment_user_picture" => "1", "toggle_comment_user_verification" => "1", "toggle_favicon" => "1", "toggle_main_menu" => "1", "toggle_secondary_menu" => "1", "default_logo" => "0", "logo_path" => "public://yorklogo-small.png", "default_favicon" => "0", "favicon_path" => "favicon.ico", "bootstrap__active_tab" => "edit-advanced", "bootstrap_fluid_container" => "0", "bootstrap_cdnbutton_colorize" => "1", "bootstrap_cdnbutton_iconize" => "1", "bootstrap_cdnforms_required_has_error" => "0", "bootstrap_cdnforms_smart_descriptions" => "1", "bootstrap_cdnforms_smart_descriptions_limit" => "1", "bootstrap_cdnforms_smart_descriptions_allowed_tags" => "b, code, em, i, kbd, span, strong", "bootstrap_cdnimage_shape" => "img-rounded", "bootstrap_cdnimage_responsive" => "1", "bootstrap_cdntable_bordered" => "1", "bootstrap_cdntable_condensed" => "0", "bootstrap_cdntable_hover" => "1", "bootstrap_cdntable_striped" => "1", "bootstrap_cdntable_responsive" => "1", "bootstrap_cdnbreadcrumb" => "1", "bootstrap_cdnbreadcrumb_home" => "0", "bootstrap_cdnbreadcrumb_title" => "1", "bootstrap_cdnnavbar_position" => "fixed-top", "bootstrap_cdnnavbar_inverse" => "0", "bootstrap_cdnpager_first_and_last" => "1", "bootstrap_cdnregion_well-navigation" => "well", "bootstrap_cdnregion_well-highlighted" => "well", "bootstrap_cdnregion_well-content" => "well", "bootstrap_cdnregion_well-sidebar_first" => "well", "bootstrap_cdnregion_well-sidebar_second" => "well", "bootstrap_cdnanchors_fix" => "1", "bootstrap_cdnanchors_smooth_scrolling" => "1", "bootstrap_cdnforms_has_error_value_toggle" => "1", "bootstrap_cdnpopover_enabled" => "1", "bootstrap_cdnpopover_animation" => "1", "bootstrap_cdnpopover_html" => "0", "bootstrap_cdnpopover_placement" => "right", "bootstrap_cdnpopover_trigger_autoclose" => "1", "bootstrap_cdnpopover_delay" => "0", "bootstrap_cdnpopover_container" => "body", "bootstrap_cdntooltip_enabled" => "1", "bootstrap_cdntooltip_animation" => "1", "bootstrap_cdntooltip_html" => "0", "bootstrap_cdntooltip_placement" => "auto right", "bootstrap_cdntooltip_delay" => "0", "bootstrap_cdntooltip_container" => "body", "bootstrap_cdntoggle_jquery_error" => "0", "bootstrap_cdn_provider" => "jsdelivr", "bootstrap_cdn_custom_css" => "https://cdn.jsdelivr.net/bootstrap/3.3.5/css/bootstrap.css", "bootstrap_cdn_custom_css_min" => "https://cdn.jsdelivr.net/bootstrap/3.3.5/css/bootstrap.min.css", "bootstrap_cdn_custom_js" => "https://cdn.jsdelivr.net/bootstrap/3.3.5/js/bootstrap.js", "bootstrap_cdn_custom_js_min" => "https://cdn.jsdelivr.net/bootstrap/3.3.5/js/bootstrap.min.js", "bootstrap_cdn_jsdelivr_version" => "3.3.6", "bootstrap_cdn_jsdelivr_theme" => "spacelab", "favicon_mimetype" => "image/vnd.microsoft.icon"))'
