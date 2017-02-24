FROM ruby:2.3.3

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim nodejs-dev

RUN mkdir /var/www && chown www-data:www-data /var/www
USER www-data

# How to use this image:
# docker build -t pacscl .
# docker run -ti -v`pwd`:/var/www/rails -v`pwd`/.bundle/usr_local_bundle:/usr/local/bundle pacscl /bin/bash 
