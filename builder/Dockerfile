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

# Copy standard Docker/ dir, which contains:
#   - empty Apkfile
#   - install gems script 'bundle_install'
#   - precompile assets script 'assets_precompile'
# (these can be overridden by the child image)
COPY Docker Docker

## ONBUILD triggers ##

# Copy any Docker/* overrides (Apkfile(s), bundle_install, assets_precompile)
ONBUILD COPY Docker/* Docker/

# Install Apkfile packages listed in all Apkfile(s)
ONBUILD RUN apk add --no-cache $(cat Docker/Apkfile* | xargs) && \
            rm -rf /var/cache/* && mkdir /var/cache/apk

# Install gem bundle 
ONBUILD COPY Gemfile* /app/
ONBUILD RUN Docker/bundle_install

# Precompile assets
ONBUILD COPY app config Rakefile bin public /app/
ONBUILD RUN Docker/assets_precompile

# Copy the whole application folder into the image
ONBUILD COPY . /app
