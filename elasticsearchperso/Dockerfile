FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.4
RUN bin/elasticsearch-plugin install ingest-attachment
#RUN bin/elasticsearch-plugin remove x-pack --purge \
#   && sed -i 's/xpack/#xpack/' config/elasticsearch.yml\
#   && sed -e "\$anetwork.host: 127.0.0.1\n" config/elasticsearch.yml
COPY elasticsearch.yml config/elasticsearch.yml
USER root
RUN chown elasticsearch:elasticsearch config/elasticsearch.yml
RUN chown -R elasticsearch:elasticsearch plugins/ingest-attachment
RUN mkdir /data && chown -R elasticsearch:elasticsearch /data
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/e1f115e4ca285c3c24e847c4dd4be955e0ed51c2/wait-for-it.sh /utils/wait-for-it.sh
RUN chown -R elasticsearch:elasticsearch /utils/wait-for-it.sh
USER elasticsearch
RUN elasticsearch -p /tmp/epid & /bin/bash /utils/wait-for-it.sh -t 0 localhost:9200 -- curl -XPUT 'http://127.0.0.1:9200/myindex' -d @index.json; kill $(cat /tmp/epid) && wait $(cat /tmp/epid); exit 0;
