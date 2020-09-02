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

## Using the images

The images are alert to an `Apkfile` which can contain a list of apk packages to 
be installed on both the builder and production images.

Here is an example that uses these base images (convox example) and also has a
dependency on 'vips' for image processing.

#### `./Apkfile`

    vips

#### `./Dockerfile`

    # the builder image build app gems and assets via ONBUILD triggers
    # it must be named 'builder', as the production image references this in
    # its build triggers.  It also installs packages listed in the Apkfile
    FROM i2wdev/rails-base-builder:ruby2.7.1-rails6.0.3.2-v1 AS builder
    ENV LANG=en_GB.UTF-8 LANGUAGE=en_GB.UTF-8

    # convox automatically uses the image called 'development' in local dev mode
    FROM builder AS development
    # for convox code sync
    COPY . /app
    CMD ["Docker/server"]

    # production build installs minimal packages, plus those listed in Apkfile
    # it copies 'builder' app code and gems, and removes all non-production data 
    FROM i2wdev/rails-base-production:ruby2.7.1-rails6.0.3.2-v1 
    CMD ["Docker/server"]

## Updating the images (notes to maintanter)

### Prepare the builder image when dependencies has been changed

Prepare the builder docker image if dependencies have changed

    cd builder
    yarn install --check-files
    bundle update
    cd ..

**Important:** change the contents of `builder/VERSION` to reflect that the
dependencies have changed (unless you have chnaged rails versions, in which case
you might want to reset the contents of VERSION to `v1`)

### Build, tag, and publish the docker images

    ./publish.sh
