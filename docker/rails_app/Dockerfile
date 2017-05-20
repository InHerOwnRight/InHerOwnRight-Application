FROM ruby:2.3.3

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim nodejs-dev

RUN mkdir /var/www && chown -R www-data:www-data /var/www
USER www-data

WORKDIR /var/www/rails

EXPOSE 3000

# How to use this image:
# docker build -t pacscl .
# docker run -ti --link solr:solr -v`pwd`:/var/www/rails -v`pwd`/.bundle/usr_local_bundle:/usr/local/bundle -p 3000:3000 pacscl /bin/bash
# docker exec -it pacscl_app_1 bash
