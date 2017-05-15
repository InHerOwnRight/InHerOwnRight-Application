FROM ruby:2.3.3

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim nodejs-dev

RUN mkdir /var/www
# These directories will be overwritten by mounted volumes when developing locally
COPY . /var/www/rails/
# If we do this, we have to add config data, e.g. database.yml, secrets, etc. Do it with environment vars?
# RUN cd /var/www/rails && git reset --hard origin/master
# RUN cp config/database.yml.example config/database.yml

# TODO remove the .env file and require the production docker-compose.yml to -v mount the real .env file
# TODO what else should be removed?
RUN chown -R www-data:www-data /var/www
USER www-data

WORKDIR /var/www/rails
RUN cd /var/www/rails && bundle

EXPOSE 3000

# How to use this image:
# docker build -t pacscl .
# docker run -ti --link solr:solr -v`pwd`:/var/www/rails -v`pwd`/.bundle/usr_local_bundle:/usr/local/bundle -p 3000:3000 pacscl /bin/bash
# docker exec -it pacscl_app_1 bash
