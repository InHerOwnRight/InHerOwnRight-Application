FROM phusion/passenger-ruby25

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    vim \
    nodejs-dev \
    tzdata \
    s3cmd \
    imagemagick

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

RUN mkdir -p /var/www/rails

RUN ln -s /var/www/rails /home/app/

WORKDIR /var/www/rails

RUN mkdir -p public/assets

COPY Gemfile* ./

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www

RUN bash -c 'echo -e "#!/bin/bash\nexport HOME=/home/app\nsu -lc \"cd /var/www/rails && bundle install && bin/delayed_job start\" app" > /etc/my_init.d/delayed_job.sh && chmod a+x /etc/my_init.d/delayed_job.sh'

USER app

RUN gem install bundler:2.1.4

RUN bundle install

COPY --chown=app:app . ./

# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi"

# Set required keys to get the rake task to run
ENV SECRET_KEY_BASE=1234
ENV AWS_ACCESS_KEY_ID=SECRET
ENV AWS_SECRET_ACCESS_KEY=SECRET
ENV AWS_BUCKET=SECRET
ENV AWS_BUCKET_REGION=SECRET
RUN RAILS_ENV=production rake assets:precompile

USER root

EXPOSE 80
