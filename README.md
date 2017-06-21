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

## Development Environment Setup

As of spring 2017, Docker on OSX runs a Linux VM to host containers. This extra layer
causes the Rails app run very slowly. For a quicker development environment on Mac, run:

    docker-compose build
    docker-compose -f docker-compose-dev.yml up

It should then be possible to setup and run the Rails app in a separate terminal:

    bundle install
    rails db:setup
    rails db:migrate

Then import the data / set up the project:

    rails setup:project

## Other Environments Setup

After installing prerequisites and cloning the repository, you should be able to
run the application using docker-compose:

    docker-compose build
    docker-compose up

In a different terminal window run:

    docker-compose run app rails db:setup

### Additional Useful Commands

    docker exec -it pacscl_app bash          # Open terminal to Rails container
    docker-compose run app [RAILS_COMMAND]   # Run typical Rails commands

### TODO how to push to DockerHub ###

    docker build -f docker/rails_app/Dockerfile -t neomindlabs/pacscl_app .
    TODO: This might get pushed automatically by docker-compose build now that we have the image name in docker-compose.yml
