FROM phusion/passenger-ruby23

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y vim nodejs-dev tzdata

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY . /var/www/rails/
# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "cd /var/www/rails && if [ ! -f ./pacscl-rails/config/database.yml ]; then cp ./pacscl-rails/config/database.yml.example ./pacscl-rails/config/database.yml; fi"
# TODO remove the .env file and require the production docker-compose.yml to -v mount the real .env file. Anything else?

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www
RUN su -c "ln -s /var/www/rails /home/app/" app

RUN su -c "cd /var/www/rails/pacscl-rails && bundle install --deployment" app
# you need a SECRET_KEY_BASE to get the rake task to run
ENV SECRET_KEY_BASE=1234
RUN su -c "cd /var/www/rails/pacscl-rails && RAILS_ENV=production rake assets:precompile" app

EXPOSE 80
