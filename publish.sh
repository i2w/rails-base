#!/bin/sh

set -e

RUBY_VERSION=$(cat builder/.ruby-version)
RAILS_VERSION=$(cat builder/Gemfile.lock | grep "\srails (" | cut -d "(" -f2 | cut -d ")" -f1)
DEPS_VERSION=$(cat builder/VERSION)

TAG="ruby${RUBY_VERSION}-rails${RAILS_VERSION}-${DEPS_VERSION}"

echo "build and push rails-base-builder ${TAG}"

docker build -t i2wdev/rails-base-builder:${TAG} \
             --build-arg RUBY_VERSION=${RUBY_VERSION} \
             --build-arg RAILS_VERSION=${RAILS_VERSION} \
             --build-arg DEPS_VERSION=${DEPS_VERSION} \
             builder

docker push i2wdev/rails-base-builder:${TAG}

echo "build and push rails-base-production ${TAG}"

docker build -t i2wdev/rails-base-production:${TAG} \
             --build-arg RUBY_VERSION=${RUBY_VERSION} \
             --build-arg RAILS_VERSION=${RAILS_VERSION} \
             --build-arg DEPS_VERSION=${DEPS_VERSION} \
             production

docker push i2wdev/rails-base-production:${TAG}

