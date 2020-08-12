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

# Install Apkfile packages
ONBUILD RUN touch /tmp/Apkfile
ONBUILD COPY Apkfile* /tmp
ONBUILD RUN apk add --no-cache $(cat /tmp/Apkfile | xargs) && \
            rm -rf /var/cache/* && mkdir /var/cache/apk

# Install app gems, and cleanup
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle install -j4 --retry 3 && \
	          bundle clean --force && \
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# Install app js dependencies via yarn
ONBUILD COPY yarn.lock package.json /app/
ONBUILD RUN yarn install --check-files

# Copy the whole application folder into the image
ONBUILD COPY . /app

# Install app assets modules. Note: we hide credentials while compiling
ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
ONBUILD RUN RAILS_ENV=production SECRET_KEY_BASE=X RAILS_PRODUCTION_KEY=X bundle exec rails assets:precompile
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true
