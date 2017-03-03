#PACSCL: In Her Own Right

## About this Application

## Development Environment Setup

#### Prerequisites

- git
- docker
- docker-compose (if you install docker without docker-compose)

After installing prerequisites and cloning the repository, you should be able to
run the application using docker-compose:

    docker-compose build
    docker-compose up

In a different terminal window run:

    docker-compose run app rails db:create
    docker-compose run app rails db:migrate


### Additional Commands

    docker exec -it pacscl_app bash          # Open terminal to Rails container
    docker-compose run app [RAILS_COMMAND]   # Run typical Rails commands