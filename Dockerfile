FROM phusion/passenger-ruby23

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim nodejs-dev tzdata

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY . /var/www/rails/
# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "cd /var/www/rails && if [ ! -f config/database.yml ]; then cp config/database.yml.example config/database.yml; fi"
# TODO remove the .env file and require the production docker-compose.yml to -v mount the real .env file. Anything else?

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www
RUN su -c "ln -s /var/www/rails /home/app/" app

RUN su -c "cd /var/www/rails && bundle install --deployment" app

EXPOSE 80
