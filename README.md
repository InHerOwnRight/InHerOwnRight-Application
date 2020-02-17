# PACSCL: In Her Own Right

## Application Overview
* The project uses [Blacklight](https://github.com/projectblacklight/blacklight) and [Solr](https://lucene.apache.org/solr/) in order to search imported document records.  
* Document metadata is imported from the [OAI API](https://www.openarchives.org/) and CSVs provided by the client via several rake tasks.
* Images related to records are stored on AWS S3 and imported via a rake task.
* This repository [pacscl](https://github.com/NeomindLabs/pacscl) is the outer project layer used to encapsulate the project with Docker.
* This repository (pacscl-rails) is the inner layer that holds the rails app.

## Prerequisites

- git
- docker
- [docker-compose](https://docs.docker.com/compose/) (if you install docker without docker-compose)

## Common Environment pre-setup

    cp .env.example .env  # you'll need to follow the instructions in this file!
    cp config/database.yml.example config/database.yml
    mkdir .bundle/usr_local_bundle
    sudo chown -R 33:50 .bundle/usr_local_bundle/ # www-data:staff
    sudo docker run -ti -v `pwd`/.bundle/usr_local_bundle:/usr/local/bundle2 pacscl_app cp -r /usr/local/bundle/* /usr/local/bundle2/

NOTE about database.yml: You'll need to copy the database and username parameters from production to the development and test environments to develop using the full docker stack

## Set up the project

    rake db:create
    rake setup:project #imports all records

## Additional Useful Commands

    docker exec -it pacscl_app bash          # Open terminal to Rails container
    docker-compose run app [RAILS_COMMAND]   # Run typical Rails commands


## Troubleshooting

- Occasionally delete development logs and stale docker containers to free up space on the disk:

    Development logs (within image): echo -n "" > development.log
    Stale Docker Containers:  sudo docker system prune -a

## Building the Docker image

    docker build -t neomindlabs/pacscl-rails:staging --no-cache .

## Pushing the Docker image to DockerHub

    docker push neomindlabs/pacscl-rails:staging
OR

    docker push neomindlabs/pacscl-rails:production

## Deploying

    ssh pacscl-staging # ssh config information in 1Password
OR

    ssh pacscl-production # ssh config information in 1Password
THEN

    docker pull neomindlabs/pacscl-rails:staging / :production
    docker-compose down
    docker-compose up

## Reloading the data from scratch

    cd ~/pacscl && docker-compose exec webapp bash
    su app
    cd /home/app/rails
    RAILS_ENV=staging rake setup:project
