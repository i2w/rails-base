FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
        build-base \
        cmake \
	postgresql-client \
        postgresql-dev \
        git \
        nodejs \
	chromium-chromedriver \
	chromium \
        yarn \
        tzdata \
        file

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
ONBUILD RUN apk add --no-cache $(cat /tmp/Apkfile | xargs)

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
ONBUILD RUN RAILS_ENV=production SECRET_KEY_BASE=X RAILS_MASTER_KEY=X \
            bundle exec rails assets:precompile
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true


