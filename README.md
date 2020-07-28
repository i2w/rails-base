# Rails base docker images

My own version of https://github.com/ledermann/docker-rails-base - please
check that out!

I'm using convox for orchestration, which automatically picks up on an intermediate
image called 'development'.

## Enable pushing docker images to github

To login to github packages, first create a personal access token which has
rights to write and read packages.  Copy the access token then

    docker login https://docker.pkg.github.com -u ianwhite

## Building, tagging and pushing the images

TODO: this can be automated

### Prepare the builder image when dependencies has been changed

Prepare the builder docker image if dependencies have changed

    cd builder
    yarn install --check-files
    bundle update
    cd ..

If dependencies have changed, or the Dockerfiles have changed, tag the commit
with the version (v1, etc) and use that in the following commands instead of v1

### Build and tag the docker images

    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 builder
    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 production

### Publish the images

    docker push docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1
    docker push docker.pkg.github.com/i2w/rails-base/rails-base-production:v1

## Using the images

The images are alert to an `Apkfile` which can contain a list of apk packages to 
be installed on both the builder and production images.

Here is an example that uses these base images (convox example)

#### Apkfile

    vips

#### Dockerfile

    FROM docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 AS builder

    FROM builder AS development
    # for convox code sync
    COPY . /app
    CMD ["bin/rails", "server", "-b", "0.0.0.0"]

    # production build
    FROM docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 AS production
    CMD ["bin/rails", "server", "-b", "0.0.0.0"]
