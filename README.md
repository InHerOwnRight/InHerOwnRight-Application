#PACSCL: In Her Own Right

## About this Application

#### Prerequisites

- git
- docker
- docker-compose (if you install docker without docker-compose)

## Development Environment Setup

As of spring 2017, Docker on OSX runs a Linux VM to host containers. This extra layer
causes the Rails app run very slowly. For a quicker development environment on Mac, run:

    docker-compose build
    docker-compose -f docker-compose-dev.yml up

It should then be possible to setup and run the Rails app in a separate terminal:

    bundle install
    rails db:setup

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