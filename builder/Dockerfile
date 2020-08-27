ARG RUBY_VERSION
ARG RAILS_VERSION
ARG DEPS_VERSION

FROM i2wdev/ruby-base:$RUBY_VERSION

LABEL maintainer="ian@i2w.me"
LABEL RUBY_VERSION=$RUBY_VERSION
LABEL RAILS_VERSION=$RAILS_VERSION
LABEL DEPS_VERSION=$DEPS_VERSION

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

# Install our APK_LIST, cleanup
RUN apk upgrade -U -a && \
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

# bundle
# bundle.1: copy Gemfile
ONBUILD COPY Gemfile* /app/
# bundle.2: install gems
ONBUILD RUN bundle install -j4 --retry 3 &&\
            bundle clean --force && \
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# assets
# assets.1: mk directories required for assets
ONBUILD RUN mkdir -p /app/bin /app/app/javascript /app/app/assets \
                     /app/config/webpack /app/config/environments /app/config/initializers
# assets.2: copy whole directories
ONBUILD COPY bin                  /app/bin
ONBUILD COPY app/assets           /app/app/assets
ONBUILD COPY app/javascript       /app/app/javascript
ONBUILD COPY config/webpack       /app/config/webpack
ONBUILD COPY config/environments  /app/config/environments
# assets.3: copy single files required into place
ONBUILD COPY Rakefile package.json yarn.* *.config.js .browsers*     /app/
ONBUILD COPY config/web*.yml config/app* config/env*.rb config/boot* /app/config/
ONBUILD COPY config/initializers/assets*.rb                          /app/config/initializers/
# assets.4: precompile assets
ONBUILD RUN RAILS_ENV=production SECRET_KEY_BASE=X bundle exec rails assets:precompile

# Copy the rest of the application into the image
ONBUILD COPY . /app/

