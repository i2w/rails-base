# Rails base docker images

My own version of https://github.com/ledermann/docker-rails-base - please
check that out!

I'm using convox for orchestration, which automatically picks up on an intermediate
image called 'development'.

The builder/development image contains everything necessary to install gems, node,
and run browser based tests via chromium.

The production image is a stripped down version of the above.

Both images are sensitive to an `Apkfile` in which you can list extra alpine packages
that must be installed in both images.

The builder image is sensitive to an `Apklocales` file, in which you can specify which
locales should be included. 

## Using the images

The images are alert to an `Apkfile` which can contain a list of apk packages to 
be installed on both the builder and production images.

Here is an example that uses these base images (convox example) and also has a
dependency on 'vips' for image processing.

#### `./Apkfile`

    vips

#### `./Apklocales
  
    en_BG
    en_US
    en_AU

#### `./Dockerfile`

    # the builder image build app gems and assets via ONBUILD triggers
    # it must be named 'builder', as the production image references this in
    # its build triggers.  It also installs packages listed in the Apkfile
    FROM docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 AS builder
    ENV LANG=en_GB.UTF-8 LANGUAGE=en_GB.UTF-8

    # convox automatically uses the image called 'development' in local dev mode
    FROM builder AS development
    # for convox code sync
    COPY . /app
    CMD ["bin/rails", "server", "-b", "0.0.0.0"]

    # production build installs minimal packages, plus those listed in Apkfile
    # it copies 'builder' app code and gems, and removes all non-production data 
    FROM docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 
    CMD ["bin/rails", "server", "-b", "0.0.0.0"]

## Updating the images (notes to maintanter)

### Enable pushing docker images to github

To login to github packages, first create a personal access token which has
rights to write and read packages.  Copy the access token then

    docker login https://docker.pkg.github.com -u <github-user-name>

### Building, tagging and pushing the images

TODO: this can be automated

#### Prepare the builder image when dependencies has been changed

Prepare the builder docker image if dependencies have changed

    cd builder
    yarn install --check-files
    bundle update
    cd ..

If dependencies have changed, or the Dockerfiles have changed, tag the commit
with the version (v1, etc) and use that in the following commands instead of v1

#### Build and tag the docker images

    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 builder
    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-production:v1 production

#### Publish the images

    docker push docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1
    docker push docker.pkg.github.com/i2w/rails-base/rails-base-production:v1
