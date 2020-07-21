# Rails base docker images

To login to github packages, first create a personal access token which has
rights to write and read packages.  Copy the access token then

    docker login https://docker.pkg.github.com -u ianwhite 

Prepare the builder docker image if dependenies have changed

    cd builder
    yarn install
    bundle install
    cd ..

If dependencies have changed, or the Dockerfiles have changed, tag the commit
with the version (v1, etc) and use that in the following commands instead of v1

Build and tag the docker images

    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-builder:v1 builder
    docker build -t docker.pkg.github.com/i2w/rails-base/rails-base-final:v1 final

Publish the images

    docker push docker.pkg.github.com/i2w/rails-base/rails-base-builder
    docker push docker.pkg.github.com/i2w/rails-base/rails-base-final
