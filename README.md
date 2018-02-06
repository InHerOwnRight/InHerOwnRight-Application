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

### TODO how to push to DockerHub ###

    cd ../pacscl-rails
    docker build -f Dockerfile --no-cache -t neomindlabs/pacscl-rails .
    docker push neomindlabs/pacscl-rails

### Loading the data

After your app is running and your database is setup, run the following commands to load all available data into the site:

    cd /var/www/rails && RAILS_ENV=production bin/rails setup:project
