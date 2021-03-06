FROM openjdk:jre-alpine

LABEL maintainer "nshou <nshou@coronocoya.net>"

ENV ES_VERSION=5.4.2 \
    KIBANA_VERSION=5.4.2

RUN apk add --quiet --no-progress --no-cache nodejs wget \
 && adduser -D elasticsearch

USER elasticsearch

WORKDIR /home/elasticsearch

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ES_VERSION} elasticsearch \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv kibana-${KIBANA_VERSION}-linux-x86_64 kibana \
 && rm -f kibana/node/bin/node kibana/node/bin/npm \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm

USER root
RUN chgrp -R 0 /home/elasticsearch/elasticsearch/config && chmod -R g+rwX /home/elasticsearch/elasticsearch/config
RUN chgrp -R 0 /home/elasticsearch/kibana/optimize && chmod -R g+rwX /home/elasticsearch/kibana/optimize
RUN chgrp -R 0 /home/elasticsearch/kibana/data && chmod -R g+rwX /home/elasticsearch/kibana/data

USER elasticsearch

CMD sh elasticsearch/bin/elasticsearch -E http.host=0.0.0.0 --quiet & kibana/bin/kibana --host 0.0.0.0 -Q

EXPOSE 9200 5601
