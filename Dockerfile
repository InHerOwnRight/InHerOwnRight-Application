FROM phusion/passenger-ruby26:2.1.0

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    vim \
    nodejs \
    tzdata \
    s3cmd \
    imagemagick \
    wget

# enable nginx in the passenger image
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

ARG RAILS_ENV=development
ENV RAILS_ENV=$RAILS_ENV

RUN mkdir -p /var/www/rails

RUN ln -s /var/www/rails /home/app/

WORKDIR /var/www/rails

RUN mkdir -p public/assets

COPY Gemfile* ./

# The app user is defined by the phusion passenger image
RUN chown -R app:app /var/www

RUN bash -c 'echo -e "#!/bin/bash\nexport HOME=/home/app\nsu -c \"cd /var/www/rails && bundle install && RAILS_ENV=${RAILS_ENV} bin/delayed_job start\" app" > /etc/my_init.d/delayed_job.sh && chmod a+x /etc/my_init.d/delayed_job.sh'

USER app

RUN gem install bundler:2.1.4

RUN which ruby && ruby --version

RUN bundle install --deployment --without development test

COPY --chown=app:app . ./

# Database.yml should be overridden by a mounted volume. This can happen in docker-compose.yml
RUN bash -lc "if [ ! -f ./config/database.yml ]; then cp ./config/database.yml.example ./config/database.yml; fi"

# Set required keys to get the rake task to run
ENV SECRET_KEY_BASE=1234
ENV AWS_ACCESS_KEY_ID=SECRET
ENV AWS_SECRET_ACCESS_KEY=SECRET
ENV AWS_BUCKET=SECRET
ENV AWS_BUCKET_REGION=SECRET
RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN bundle exec whenever --update-crontab

COPY --chown=root:root provisioning/docker-entrypoint.sh /
#COPY --chown=root:root provisioning/nginx/nginx.conf /etc/nginx/
#COPY --chown=root:root provisioning/nginx/sites-available/* /etc/nginx/sites-available/
COPY --chown=root:root provisioning/nginx/ /etc/nginx/

USER root
RUN ln -s /etc/nginx/sites-available/rails.conf /etc/nginx/sites-enabled/rails.conf

# Install bad bot blocker
RUN wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/sbin/install-ngxblocker \
 && chmod +x /usr/local/sbin/install-ngxblocker \
 && cd /usr/local/sbin \
 && ./install-ngxblocker -x \
 && chmod +x /usr/local/sbin/setup-ngxblocker \
 && chmod +x /usr/local/sbin/update-ngxblocker \
 && ./setup-ngxblocker -x -e conf

COPY provisioning/var/ /var/

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/sbin/my_init"]
