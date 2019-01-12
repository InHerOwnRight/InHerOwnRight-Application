#PACSCL: In Her Own Right

## About this Application

#### Prerequisites

- git
- docker
- docker-compose (if you install docker without docker-compose)

## Common Environment pre-setup

    cp .env.sample .env  # you'll need to follow the instructions in this file!
    cp config/database.yml.example config/database.yml
    mkdir .bundle/usr_local_bundle
    sudo chown -R 33:50 .bundle/usr_local_bundle/ # www-data:staff
    sudo docker run -ti -v `pwd`/.bundle/usr_local_bundle:/usr/local/bundle2 pacscl_app cp -r /usr/local/bundle/* /usr/local/bundle2/

NOTE about database.yml: You'll need to copy the database and username parameters from production to the development and test environments to develop using the full docker stack

## Set up the project

    rake db:migrate
    rake setup:project

### Additional Useful Commands

    docker exec -it pacscl_app bash          # Open terminal to Rails container
    docker-compose run app [RAILS_COMMAND]   # Run typical Rails commands

### Troubleshooting

If you get an error message that looks like this:

    E: Failed to fetch http://security.ubuntu.com/ubuntu/pool/main/t/tzdata/tzdata_2018g-0ubuntu0.18.04_all.deb  404  Not Found [IP: 91.189.88.162 80]
    E: Unable to fetch some archives, maybe run apt-get update or try with --fix-missing?

Add "--no-cache" to your docker build command. It caused by a cache of the apt sources that has become out of date.

### TODO how to push to DockerHub ###

    cd ../pacscl-rails
    docker build -f Dockerfile --no-cache -t neomindlabs/pacscl-rails .
    docker push neomindlabs/pacscl-rails

### Deploying to Staging

    docker build -t --no-cache neomindlabs/pacscl-rails:staging .
    docker push neomindlabs/pacscl-rails:staging

### Reloading the data on Staging from scratch

    cd ~/pacscl && docker-compose exec webapp bash
    su app
    cd /home/app/rails
    RAILS_ENV=staging rake db:drop db:create setup:project

### Loading the data

After your app is running and your database is setup, run the following commands to load all available data into the site:

    cd /var/www/rails && RAILS_ENV=production bin/rails setup:project
