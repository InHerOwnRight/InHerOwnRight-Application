FROM phusion/passenger-ruby25

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    vim \
    nodejs-dev \
    tzdata \
    s3cmd \
    imagemagick

RUN su -lc "rvm install 'ruby-2.5.7'"
RUN su -lc 'rvm --default use ruby-2.5.7' app

RUN su -lc "gem install bundler:1.17.3"

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

RUN mkdir -p /var/www/rails

RUN ln -s /var/www/rails /home/app/

WORKDIR /var/www/rails

RUN mkdir -p public/assets

COPY Gemfile* ./

RUN chown -R app:app /var/www

USER app

RUN bundle install

COPY --chown=app:app . ./

# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi"

ENV SECRET_KEY_BASE=1234
ENV AWS_ACCESS_KEY_ID=SECRET
ENV AWS_SECRET_ACCESS_KEY=SECRET
RUN RAILS_ENV=production bundle exec rake assets:precompile

# RUN bash -lc 'echo -e "#!/bin/bash\nexport HOME=/home/app\nsu -lc \"cd /var/www/rails && bin/delayed_job start\" app" > /etc/my_init.d/delayed_job.sh && chmod a+x /etc/my_init.d/delayed_job.sh'

USER root

EXPOSE 80
