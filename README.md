# Rails base docker images

My own version of https://github.com/ledermann/docker-rails-base - please
check that out!

I'm using convox for orchestration, which automatically picks up on an intermediate
image called 'development'.

## Enable pushing docker images to github

To login to github packages, first create a personal access token which has
rights to write and read packages.  Copy the access token then

    docker login https://docker.pkg.github.com -u ianwhite

## Building, tagging and psuhing the images

TODO: this can be automated

### Prepare the builder image when dependencies has been changed

Prepare the builder docker image if dependencies have changed

    cd builder
    yarn install --check-files
    bundle install
    cd ..

If dependencies have changed, or the Dockerfiles have changed, tag the commit
with the version (v1, etc) and use that in the following commands instead of v1

### Build and tag the docker images

    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 builder
    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-development:v1 development
    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 production

### Publish the images

    docker push docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1
    docker push docker.pkg.github.com/i2w/rails-base/rails-base-development:v1
    docker push docker.pkg.github.com/i2w/rails-base/rails-base-production:v1

## Using the images

Here is an example Dockerfile that uses these base images

    FROM docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 AS builder
    FROM docker.pkg.github.com/i2w/rails-base/rails-base-development:v1 AS development
    FROM docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 AS production
