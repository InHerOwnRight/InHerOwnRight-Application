FROM phusion/passenger-ruby23

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    vim \
    nodejs-dev \
    tzdata \
    s3cmd \
    imagemagick

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

COPY . /var/www/rails/
# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "cd /var/www/rails && if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi"
# TODO remove the .env file and require the production docker-compose.yml to -v mount the real .env file. Anything else?

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www
RUN su -c "ln -s /var/www/rails /home/app/" app

USER app

RUN bundle install

# RUN su -c 'echo -e "#!/bin/bash\ncd /var/www/rails && bundle install && bin/delayed_job start" > /etc/my_init.d/delayed_job.sh && chmod a+x /etc/my_init.d/delayed_job.sh'

COPY --chown=app:app . ./

# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi"

# Set required keys to get the rake task to run
ENV SECRET_KEY_BASE=1234
ENV AWS_ACCESS_KEY_ID=SECRET
ENV AWS_SECRET_ACCESS_KEY=SECRET
RUN RAILS_ENV=production rake assets:precompile

USER root

EXPOSE 80
