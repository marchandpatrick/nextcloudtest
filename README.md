# NEXTCLOUD 

*** problem with fulltextsearch / elastic search installation: reproducible example ***

to reproduce:

prerequisite: install docker and docker-compose

clone this repo

git clone 

setup context:
cd nextcloudtest
sudo ./setup_owncloudtest.sh


execute test, and examine results
sudo ./launch_test.sh


My results:

My question: what's wrong with my setup to access elasticsearch via platform?

# Mise en place de la solution décrite sous:

https://github.com/nextcloud/docker/tree/master/.examples/docker-compose/with-nginx-proxy/mariadb-cron-redis/apache
test sous:

répertoire:
/home/marchand/nextcloud

Pour mise en service:

personnaliser les fichiers dbPont .env et docker-compose.yml

cat dbPont.env
MYSQL_PASSWORD=choco
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud
MYSQL_ROOT_PASSWORD=chocochoco
VIRTUAL_HOST=nextcloud.mmpsm.ovh
LETSENCRYPT_HOST=nextcloud.mmpsm.ovh
LETSENCRYPT_EMAIL=patrick.marchand@cetim.fr

cat docker-compose.yml
  proxy:
version: '3'

services:
  db:
    image: mariadb
    container_name: nextcloud-mariadb
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    restart: unless-stopped
    volumes:
      - ./vols/db:/var/lib/mysql
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    env_file:
      - dbPont.env

  redis:
    image: redis
    container_name: nextcloud-redis
    restart: always

  app:
    build: ./app
    restart: unless-stopped
    container_name: nextcloud-app
    volumes:
#      - ./vols/nextcloud:/var/www/html
      - /mnt/sdd1/data:/var/www/html
#      - /mnt/sdd1/data:/var/www/nextcloud
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    environment:
      - MYSQL_HOST=db
      - discovery.type=single-node
    env_file:
      - dbPont.env
    depends_on:
      - db
      - redis
      - letsencrypt-companion
      - proxy
    networks:
      - proxy-tier
      - default
  cron:
    build: ./app
    container_name: nextcloud-cron
    restart: unless-stopped
    volumes:
#      - ./vols/nextcloud:/var/www/html
#      - /mnt/sdd1/data:/var/www/nextcloud
      - /mnt/sdd1/data:/var/www/html
    entrypoint: /cron.sh
    depends_on:
      - db
      - redis

    build: ./proxy
    container_name: nextcloud-proxy
    restart: unless-stopped
    ports:
      - 80:80
      - 443:443
    labels:
      com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    volumes:
      - ./vols/certs:/etc/nginx/certs:ro
      - ./vols/vhost.d:/etc/nginx/vhost.d
      - ./vols/html:/usr/share/nginx/html
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    networks:
      - proxy-tier

  letsencrypt-companion:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: nextcloud-letsencrypt
    restart: unless-stopped
    volumes:
      - ./vols/certs:/etc/nginx/certs
      - ./vols/vhost.d:/etc/nginx/vhost.d
      - ./vols/html:/usr/share/nginx/html
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    networks:
      - proxy-tier
    depends_on:
      - proxy
  elasticsearch:
#    image: dsteinkopf/elasticsearch-ingest-attachment
    build: ./elasticsearchperso
    image: elasticsearchperso
#    container_name: nextcloud-elasticsearch
    container_name: Elasticsearch
    restart: unless-stopped
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      - discovery.type=single-node
    volumes:
      - ./vols/elasticsearch_data:/usr/share/elasticsearch/data
      - ./vols/es/readonlyrest.yml:/usr/share/elasticsearch/config/readonlyrest.yml
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
    networks:
      - proxy-tier
networks:
  proxy-tier:



lancer:
docker-compose up -d

accès par:
nextcloud.mmpsm.ovh

utilisateur:
marchand
chocochoco60

données patagées avec les containers:
/home/marchand/nextcloud/vols
/mnt/sdd1/data
dont données: /mnt/sdd1/data/data


fichier de configuration nextcloud:
dont données: /mnt/sdd1/data/data/config/config.php
<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
    'host' => 'redis',
    'port' => 6379,
  ),
  'instanceid' => 'oc482qzw5srg',
  'passwordsalt' => '+j70OWOrWRSr5aSCrZPaRo9Nf2YGWl',
  'secret' => '0LngfX7sUPe1e6vkG+8Z+bYh5rGsUHtnNrg7/pvBy6Awa5MG',
  'trusted_domains' => 
  array (
    0 => 'nextcloud.mmpsm.ovh',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '15.0.0.10',
  'overwrite.cli.url' => 'https://nextcloud.mmpsm.ovh',
  'dbname' => 'nextcloud',
  'dbhost' => 'db',
  'dbport' => '',
  'dbtableprefix' => '',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextcloud',
  'dbpassword' => 'choco',
  'installed' => true,
  'loglevel' => 2,
  'maintenance' => false,
  'theme' => '',
  'updater.secret' => '$2y$10$DvfiiDoXaIuRSgHO10I5q.px8TrQGXMnIFRqA5I/yW6lYKRwaI3YW',
);





intallation de l'application  rightclick
=> la charger par git clone
cd /home/marchand/nextcloud/apps
git clone https://github.com/NastuzziSamy/files_rightclick.git  
=> l'activer dans parametres nextcloud


tentative de mise en oeuvre de full text search

installer elastcsearch, voir plus haut docker-compose

fichier de configuration elasticsearch
/home/marchand/nextcloud/elasticsearchperso/elasticsearch.yml
cluster.name: "cloud1"
network.host: 0.0.0.0

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1
#xpack.license.self_generated.type: basic
# https://stackoverflow.com/questions/35526532/how-to-add-an-elasticsearch-index-during-docker-build
#es.path.data: /data
xpack.security.enabled: false
#path.data: /data
discovery.type: single-node



Securité pour elasticsearch:
/home/marchand/nextcloud/vols/es/readonlyrest.yml
readonlyrest:
  access_control_rules:
  - name: Accept requests from cloud1 onmyindex-index
    groups: ["cloud1"]
    indices: ["myindex"]
    
  users:
  - username: marchand
    auth_key: marchand:choco
    groups: ["cloud1"]

installer les applis sous nextcloud:

parametrer les applis:
docker exec -ti -u www-data nextcloud-app php ./occ fulltextsearch:configure '{"search_platform":"OCA\\FullTextSearch_ElasticSearch\\Platform\\ElasticSearchPlatform"}'
docker exec -ti -u www-data nextcloud-app php ./occ fulltextsearch_elasticsearch:configure "{\"elastic_host\":\"http://marchand:choco@localhost:9200\",\"elastic_index\":\"myindex\"}"
docker exec -ti -u www-data nextcloud-app php ./occ fulltextsearch:configure "{\"files_pdf\":\"1\",\"files_office\":\"1\"}"

Vérifications de fonctionnement:
curl 'localhost:9200/_cat/indices?v'
marchand@marchand-GB-BXBT-2807:~/nextcloud$ curl 'http://marchand:choco@localhost:9200/_cat/indices?v'
health status index                         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .watcher-history-7-2018.12.28 LSkZqFLSRUue5KQ7dpBevw   1   0        540            0    651.8kb        651.8kb
green  open   .watcher-history-7-2018.12.19 VrFI6dWdQsK5i1qe8wf5WQ   1   0       8086            0      9.7mb          9.7mb
green  open   .triggered_watches            yjfaXn24S_SfE69i0YTlpQ   1   0          0            0    473.2kb        473.2kb
green  open   .monitoring-es-6-2018.12.28   yc-yBPDESBuNy09klS9apQ   1   0       8287           11      3.9mb          3.9mb
green  open   .watcher-history-7-2018.12.29 QLk6ta66QM6YnOoW-nhd6w   1   0       3089            0      6.9mb          6.9mb
green  open   .monitoring-es-6-2018.12.29   PinfjoMQTcuoD01cHuyx1Q   1   0      43608           40     34.2mb         34.2mb
green  open   .watcher-history-7-2018.12.20 9BzJ-l5OR9mjn3RCoM9g4Q   1   0       2888            0      3.3mb          3.3mb
green  open   .watches                      ODXhFouLQaakgWN9AyirLg   1   0          6            0    100.9kb        100.9kb
green  open   .watcher-history-7-2018.12.18 wyDH8_PvRB-ve1OHPcMusg   1   0        564            0    723.1kb        723.1kb
green  open   .monitoring-alerts-6          Dber7mNISaOj1ZAHQRyhBg   1   0          3            0     17.9kb         17.9kb


docker exec -ti -u www-data nextcloud-app php ./occ  fulltextsearch:check
probleme  à résoudre!
Interrogations: nom du cluster dans elasticsearch.yml, nom du groupe dans readonlyrest.yml


docker exec -ti -u www-data nextcloud-app php ./occ fulltextsearch:test --platform_delay 30
marchand@marchand-GB-BXBT-2807:~/nextcloud$ docker exec -ti -u www-data nextcloud-app php ./occ  fulltextsearch:test
 
.Testing your current setup:  
Creating mocked content provider. ok  
Testing mocked provider: get indexable documents. (2 items) ok  
Loading search platform. PMplateforme (OCA\FullTextSearch\Service\PlatformService)
PMplateforme ()
(Elasticsearch) ok  
Testing search platform. fail 
In Test.php line 299:
                                          
  Search platform (Elasticsearch) down ?  
                                          

fulltextsearch:test [--output [OUTPUT]] [-j|--json] [-d|--platform_delay PLATFORM_DELAY]

Interrogations: nom du cluster dans elasticsearch.yml, nom du groupe dans readonlyrest.yml

curl http://127.0.0.1:9200/_cluster/health?pretty
{
  "cluster_name" : "cloud1",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
creer un index test sur une réplique
curl -H "Content-Type: application/json" -XPUT http://127.0.0.1:9200/test -d '{"number_of_replicas": 1}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

Ingest a document to elasticsearch:
curl -H "Content-Type: application/json" -XPUT http://127.0.0.1:9200/test/docs/1 -d '{"name": "ruan"}'
{"_index":"test","_type":"docs","_id":"1","_version":1,"result":"created","_shards":{"total":2,"successful":1,"failed":0},"_seq_no":0,"_primary_term":1}

curl http://127.0.0.1:9200/_cat/indices?v
health status index                         uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .watcher-history-7-2018.12.28 LSkZqFLSRUue5KQ7dpBevw   1   0        540            0    651.8kb        651.8kb
green  open   .watcher-history-7-2018.12.19 VrFI6dWdQsK5i1qe8wf5WQ   1   0       8086            0      9.7mb          9.7mb
green  open   .triggered_watches            yjfaXn24S_SfE69i0YTlpQ   1   0          0            0      753kb          753kb
green  open   .monitoring-es-6-2018.12.28   yc-yBPDESBuNy09klS9apQ   1   0       8287           11      3.9mb          3.9mb
green  open   .watcher-history-7-2018.12.29 QLk6ta66QM6YnOoW-nhd6w   1   0       7164            0     11.5mb         11.5mb
green  open   .monitoring-es-6-2018.12.29   PinfjoMQTcuoD01cHuyx1Q   1   0     101052          119     58.1mb         58.1mb
yellow open   test                          Krt5F4bUTCKA2AJVAsMQ6g   5   1          1            0      4.2kb          4.2kb
green  open   .watcher-history-7-2018.12.20 9BzJ-l5OR9mjn3RCoM9g4Q   1   0       2888            0      3.3mb          3.3mb
green  open   .watches                      ODXhFouLQaakgWN9AyirLg   1   0          6            0    117.7kb        117.7kb
green  open   .watcher-history-7-2018.12.18 wyDH8_PvRB-ve1OHPcMusg   1   0        564            0    723.1kb        723.1kb
green  open   .monitoring-alerts-6          Dber7mNISaOj1ZAHQRyhBg   1   0          4            0     23.8kb         23.8kb






gestion des index
docker exec -ti -u www-data nextcloud-app php ./occ  fulltextsearch:stop

docker exec -ti -u www-data nextcloud-app php ./occ fulltextsearch:index
docker exec nextcloud-app su -l www-data -s /bin/sh -c "php -d memory_limit=4G -f /var/www/html/occ fulltextsearch:index -v"


curl 'localhost:9200/_cat/indices?v'

1.  Back everything up first.
2.  Disable access to Nextcloud. (maintenance mode)
3.  Move the data folder.
4.  Edit the database table oc_storage. Change the local::/path/to/data to local::/new/path/to/data.
5.  Edit the config.php datadirectory line to reflect the new path.
6.  Turn off maintenance mode.

id www-data

uid=33(www-data) gid=33(www-data) groupes=33(www-data)

chown -R www-data:www-data "repertoiredesdonnees"


Executer occ pour mettre à jour les fichiers dans la base
docker exec --user www-data apache_app_1 php occ files:scan --all

commandes utiles

docker-compose down -v
docker container ps
docker container stop 'idducontainer'
docker container rm 'idducontainer'
docker volume ls
docker volumes inspect "nomduvolume"
=> donne l'IP pour acceder à l'application
http://192.168.112.4/



https://soozx.fr/deplacer-repertoire-donnees-data-nextcloud-sur-disque-externe/


sudo gedit /var/snap/docker/common/var-lib-docker/volumes/apache_monnextcloud/_data/config/config.php



 guess you could try two ways - create a large filesystem on another disk (or elsewhere), integrate it into Nextcloud using the external storage app and move the content there, which is how I manage my 42TB storage array whilst keeping it available via other means (CIFs, SFTP, etc):

‘datadirectory’ => ‘/private_html/datastorage’,

Make sure no cron jobs are running
Stop apache
Move /data to the new location
Create a symlink from the original location to the new location
Ensure permissions are still correct
Restart apache
(Note, you may need to configure your webserver to support symlinks)
Which is supported by Nextcloud.


1: Log out of Nextcloud’s web interface.
2: Move the folder to the new location.
3: Edit config/config.php and adjust the data directory path
4: Run ./occ files:scan --all
5: Log back into the web interface.

0: Back everything up first.
1: Disable access to Nextcloud. (maintenance mode)
2: Move the data folder.
3: Edit the database table oc_storage. Change the local::/path/to/data to local::/new/path/to/data.
4: Edit the config.php datadirectory line to reflect the new path.
5: Turn off maintenance mode.



Mettre en service phpmyadmin:

https://hub.docker.com/r/phpmyadmin/phpmyadmin/

Usage behind reverse proxys
Set the variable PMA_ABSOLUTE_URI to the fully-qualified path (https://pma.example.net/) where the reverse proxy makes phpMyAdmin available.

docker run --name myadmin -d -e PMA_HOST=dbhost -p 8080:80 phpmyadmin/phpmyadmin

