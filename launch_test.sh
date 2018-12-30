#!/bin/bash

# cat elasticsearch.yml
cat ./elasticsearchperso/elasticsearch.yml

# nextcloud config  file
cat vols/config/config.php

# verify access to elasticsearch
curl 'localhost:9200/_cat/indices?v'

# check access to elastictsearch via nextcloud
docker exec -ti -u www-data nextcloud-app php ./occ  fulltextsearch:check

# pb to be examined : platform not found!
docker exec -ti -u www-data nextcloud-app php ./occ  fulltextsearch:check


