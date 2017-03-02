# For more see https://github.com/jiaola/blacklight-docker/tree/07cb898e0ae115bdff41b2801d360a81d19cda14/images/solr

FROM solr:5.5

USER root

ENV PATH /opt/solr/bin:${PATH}
ENV SOLR_HOME /var/solr/data/
ENV BLACKLIGHT_CORE ${SOLR_HOME}blacklight/

RUN mkdir -p ${BLACKLIGHT_CORE}

ADD docker/solr/solr.xml ${SOLR_HOME}
ADD docker/solr/core.properties ${BLACKLIGHT_CORE}

ADD docker/solr/gitdownloader-1.0.jar /opt/solr/gitdownloader-1.0.jar

RUN java -jar /opt/solr/gitdownloader-1.0.jar https://api.github.com/repos/projectblacklight/blacklight/contents/solr/conf ${BLACKLIGHT_CORE}conf

VOLUME ["/var/solr"]

WORKDIR /opt/solr
CMD ["sh", "-c", "solr start -f"]

EXPOSE 8983

# CMD solr start -f
# docker build -t blacklight-solr .
# docker run -ti -d --name blacklight-solr -p 8983:8983 blacklight-solr
# docker-machine ip default 192.168.99.100