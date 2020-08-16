# syntax = docker/dockerfile:1.0-experimental
FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

ENV APK_LIST build-base \
             chromium \
             chromium-chromedriver \
             cmake \
             file \
             git \
             musl-locales \
             nodejs \
             postgresql-client \
             postgresql-dev \
             tzdata \
             yarn 

# Install edge repositories and our APK_LIST, cleanup
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/main" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add --no-cache $APK_LIST && \
    rm -rf /var/cache/* && mkdir /var/cache/apk

WORKDIR /app

# Install standard Node modules
COPY package.json* yarn.lock* /app/
RUN yarn install --check-files

# Install standard gems
COPY Gemfile* /app/
RUN gem update bundler && \
    bundle config build.sassc --disable-march-tune-native && \
    bundle install -j4 --retry 3

## ONBUILD triggers ##

# Install Apkfile packages listed in all Apkfile(s)
ONBUILD RUN touch /app/Apkfile
ONBUILD COPY Apkfile* /app/
ONBUILD RUN apk add $(cat /app/Apkfile* | xargs) && \
            rm -rf /var/cache/* && mkdir /var/cache/apk

# Install gem bundle 
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle install -j4 --retry 3 &&\
            bundle clean --force && \
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# Copy files that affect assets, then precompile assets
ONBUILD RUN $(cd /app; mkdir -p app/javascript app/assets config bin public vendor/assets)
ONBUILD COPY package.json yarn.lock *.config.js Rakefile /app/
ONBUILD COPY app/javascript               /app/app/javascript
ONBUILD COPY app/assets                   /app/app/assets
ONBUILD COPY bin                          /app/bin/
ONBUILD COPY config                       /app/config/
ONBUILD COPY public                       /app/public/
ONBUILD COPY vendor/.keep vendor/assets*  /app/vendor/assets
ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
ONBUILD RUN RAILS_ENV=production SECRET_KEY_BASE=X RAILS_PRODUCTION_KEY=X bundle exec rails assets:precompile
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true

# Copy the rest of the application into the image
ONBUILD COPY . /app/
