# PACSCL: In Her Own Right

## Application Overview
* The project uses [Blacklight](https://github.com/projectblacklight/blacklight) and [Solr](https://lucene.apache.org/solr/) in order to search imported document records.  
* Document metadata is imported from the [OAI API](https://www.openarchives.org/) and CSVs provided by the client via several rake tasks.
* Images related to records are stored on AWS S3 and imported via a rake task.
* This repository [pacscl](https://github.com/NeomindLabs/pacscl) is the outer project layer used to encapsulate the project with Docker.
* This repository (pacscl-rails) is the inner layer that holds the rails app.

## Development concerns

### Prerequisites

- git
- docker
- [docker-compose](https://docs.docker.com/compose/) (if you install docker without docker-compose)

### Common Rails Environment pre-setup

    cp .env.example .env  # you'll need to follow the instructions in this file!
    cp config/database.yml.example config/database.yml
    mkdir .bundle/usr_local_bundle
    sudo chown -R 33:50 .bundle/usr_local_bundle/ # www-data:staff
    sudo docker run -ti -v `pwd`/.bundle/usr_local_bundle:/usr/local/bundle2 pacscl_app cp -r /usr/local/bundle/* /usr/local/bundle2/

NOTE about database.yml: You'll need to copy the database and username parameters from production to the development and test environments to develop using the full docker stack

### Rails application setup

    rake db:create
    rake setup:project #imports all records

### Additional Useful Commands

    docker exec -it pacscl_app bash          # Open terminal to Rails container
    docker-compose run app [RAILS_COMMAND]   # Run typical Rails commands


### Troubleshooting

- Occasionally delete development logs and stale docker containers to free up space on the disk:

    Development logs (within image): echo -n "" > development.log
    Stale Docker Containers:  sudo docker system prune -a

### Building the Docker image

    docker build -t neomindlabs/pacscl-rails:staging --build-arg RAILS_ENV=staging --no-cache .

Or

    docker build -t neomindlabs/pacscl-rails:production-`date +%F` --build-arg RAILS_ENV=production --no-cache .

## Pushing the Docker image to DockerHub

    docker push neomindlabs/pacscl-rails:staging
OR

    docker push neomindlabs/pacscl-rails:production-`date +%F`
    docker image tag neomindlabs/pacscl-rails:production-`date +%F` neomindlabs/pacscl-rails:production
    docker push neomindlabs/pacscl-rails:production

### Deploying

    ssh pacscl-staging # ssh config information in 1Password
OR

    ssh pacscl-production # ssh config information in 1Password
THEN

    docker pull neomindlabs/pacscl-rails:staging # (or :production)
    docker-compose down
    docker-compose up

### Regular maintenance

The Production and Staging environments shouldn't need anything to keep running.
Over time, there will be Rails updates, Ruby updates, and Docker image updates available.

#### Upgrading Ruby version

As happened during the 2021 maintenance of this project, occassionally the Docker image may need to be updated to use
a newer version of Ruby, because the one we were using reached the end of life. In this situation, the high-level process
for upgrading is

1) Upgrade Rails (if necessary) to a version that will work with a version of Ruby that is still receiving updates
2) Upgrade the Ruby version in the Gemfile and .ruby-version file
3) Update the Dockerfile to reference a newer version of the Passenger base image.

## Environments

There are [Production](https://inherownright.org) and [Staging](https://pacscl.neomindlabs.com) environments.
Development should be done on a copy of the app running on the developer's computer.

If you would like to make an exact copy of the state of en environment, e.g. to promote Staging to Production,
or to reproduce an issue from Production in your development environment, please follow the instructions in the section
called "Transferring state" below.

## Data-related tasks

### Reloading the data from scratch

    cd ~/pacscl && docker-compose exec webapp bash
    su app
    cd /home/app/rails
    RAILS_ENV=staging rake setup:project

### Reindexing data for search

    cd ~/pacscl && docker-compose exec webapp bash
    su app
    cd /home/app/rails
    RAILS_ENV=staging rake sunspot:reindex

### Processing new images

To process new images on S3 from their inbox folders, run the following rake command

    bin/rake process_images

### Transferring state

To capture a snapshot of the production database:
    docker-compose exec db bash
    su postgres -c 'pg_dump --no-acl --no-owner --clean pacscl_production' | gzip > /var/lib/postgresql/data/pacscl-production-`date +%F`.sql.gz
    exit
    sudo mv data/postgres/pacscl-production-`date +%F`.sql.gz ~/ && sudo chown ubuntu:ubuntu ~/pacscl-production-`date +%F`.sql.gz

To load it locally:
    scp pacscl-production:pacscl-production-`date +%F`.sql.gz db/snapshots/
    bin/rake db:drop db:create
    gunzip -c db/snapshots/pacscl-production-`date +%F`.sql.gz | psql -U postgres -h db pacscl_development

Then reindex Solr:
    bin/rake sunspot:reindex

### Harvesting new data

The preferred method of harvesting new data is from the web. When logged into the site as an administrator,
there will be a dropdown menu displaying the email address of the currently-logged in user at the top-right of the screen,
adjacent to the "PACSCL" logo. Clicking this menu will reveal, among other choices, the option to
"Harvest CSV data", or "Harvest OAI data". Using this tool to harvest new data will automatically harvest new metadata,
(into raw_records) create/update records (and associated tags/metadata), assign images, and re-index. Instructions for
accomplishing these tasks "manually" from the commandline follow.

#### Harvesting new metadata from OAI

To re-import metadata from all known OAI sources, run the following rake task:

    bin/rake import_metadata:all_oai

To see a listing of individual OAI import sub-tasks available (e.g. bin/rake import_metadata:drexel),
run the following command:

    bin/rake -T import_metadata

#### Import updated images

    bin/rake import_images:all

If, for some reason, you need to update images for an single record, or group of records, this should do it:

    records.each do |record|
      record.rescan_images!
    end

#### Rebuilding records / tags from updated metadata

    bin/rake import_metadata:reimport_all

To accomplish this manually for a record or group of records, from the Rails console:

    records.each do |record|
      Record.create_from_raw_record(record.raw_record)
    end

Similarly, this can be done with a group of raw_records:

    raw_records.each do |raw_record|
      Record.create_from_raw_record(raw_record)
    end

