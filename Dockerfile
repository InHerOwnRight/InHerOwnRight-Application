FROM phusion/passenger-ruby25

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y neovim nodejs-dev tzdata

RUN su -lc "rvm install 'ruby-2.5.7'" app
RUN su -lc 'rvm --default use ruby-2.5.7' app

RUN su -lc "gem install bundler:1.17.3"

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY . /var/www/rails/
# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN su -lc "cd /var/www/rails && if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi" app
# TODO remove the .env file and require the production docker-compose.yml to -v mount the real .env file. Anything else?

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www
RUN su -lc "ln -s /var/www/rails /home/app/" app

# this needs rake 13.0.1. It doesn't work if you specify a version, but does install that version if you don't specify one.
RUN yes | gem uninstall --all -i /usr/local/rvm/rubies/ruby-2.5.7/lib/ruby/gems/2.5.0 rake
# RUN su -lc "cd /var/www/rails && gem update --system && gem update bundler rake && bundle install --deployment" app
RUN su -lc "cd /var/www/rails && gem update --system && gem update bundler rake && bundle install" app
# you need a SECRET_KEY_BASE to get the rake task to run
ENV SECRET_KEY_BASE=1234
RUN su -lc "cd /var/www/rails && RAILS_ENV=production rake assets:precompile" app

EXPOSE 80
