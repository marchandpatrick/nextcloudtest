#!/bin/bash

# make shure docker and docker-compose are installed
# TBD
docker-compose build
docker-compose up -d
#
NCPATH=/var/www/html
NC_APPS_PATH=$NCPATH/apps
ICyan='\e[0;96m'        # Cyan
INDEX_USER=myindex

# install owncloud apps for fulltextsearch
# cf Nextcloud VM setup batch script

# Wait for bootstraping
docker restart elasticsearch
countdown "Waiting for docker bootstraping..." "20"
docker logs elasticsearch

# Get Full Text Search app for nextcloud
print_text_in_color "$ICyan" "installer les apps..."

install_and_enable_app fulltextsearch
install_and_enable_app fulltextsearch_elasticsearch
install_and_enable_app files_fulltextsearch
chown -R www-data:www-data $NC_APPS_PATH

# Final setup
print_text_in_color "$ICyan" "setup fulltextsearch..."

occ_command fulltextsearch:configure '{"search_platform":"OCA\\FullTextSearch_ElasticSearch\\Platform\\ElasticSearchPlatform"}'
print_text_in_color "$ICyan" "setup fulltextsearch_elasticsearch..."

#occ_command fulltextsearch_elasticsearch:configure "{\"elastic_host\":\"http://${INDEX_USER}:${ROREST}@localhost:9200\",\"elastic_index\":\"${INDEX_USER}-index\"}"
occ_command fulltextsearch_elasticsearch:configure "{\"elastic_host\":\"http://localhost:9200\",\"elastic_index\":\"${INDEX_USER}\"}"
print_text_in_color "$ICyan" "setup files_fulltextsearch..."

occ_command files_fulltextsearch:configure "{\"files_pdf\":\"1\",\"files_office\":\"1\"}"
if occ_command fulltextsearch:index < /dev/null
then
msg_box "Full Text Search was successfully installed!"
fi


# T&M Hansson IT AB © - 2018, https://www.hanssonit.se/

## If you want debug mode, please activate it further down in the code at line ~60

# FUNCTIONS #

msg_box() {
local PROMPT="$1"
    whiptail --msgbox "${PROMPT}" "$WT_HEIGHT" "$WT_WIDTH"
}

is_root() {
    if [[ "$EUID" -ne 0 ]]
    then
        return 1
    else
        return 0
    fi
}
# countdown 'message looks like this' 10
countdown() {
print_text_in_color "$ICyan" "$1"
secs="$(($2))"
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
}

print_text_in_color() {
	printf "%b%s%b\n" "$1" "$2" "$Color_Off"
}


install_and_enable_app() {
# Download and install $1
if [ ! -d "$NC_APPS_PATH/$1" ]
then
    print_text_in_color "$ICyan" "Installing $1..."
    # occ_command not possible here because it uses check_command and will exit if occ_command fails
    result=$(sudo -u www-data php ${NCPATH}/occ app:install "$1")
    if [ "$result" = "Error: Could not download app $1" ]
    then
msg_box "The $1 app could not be installed.
Probably it's not compatible with $(occ_command -V).

You can try to install the app manually after the script has finished,
or when a new version of the app is released with the following command:

'sudo -u www-data php ${NCPATH}/occ app:install $1'"
    fi
fi

# Enable $1
if [ -d "$NC_APPS_PATH/$1" ]
then
    occ_command app:enable "$1"
    chown -R www-data:www-data "$NC_APPS_PATH"
fi
}

