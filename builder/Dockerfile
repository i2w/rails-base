FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
        build-base \
        cmake \
	postgresql-dev \
        git \
        nodejs \
        yarn \
        tzdata \
        file

WORKDIR /app

# Install standard Node modules
COPY package.json yarn.lock* /app/
RUN yarn install --check-files

# Install standard gems
COPY Gemfile* /app/
RUN gem update bundler && \
    bundle config --local build.sassc --disable-march-tune-native && \
    bundle install -j4 --retry 3

# ONBUILD triggers - when an image is built from this image 
#   - install app gems, remove unneeded ones, and cleanup
#   - install app assets (on top of the default yarn packages)
#   - copy the application into place

# Install all gems, and cleanup
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle install -j4 --retry 3 && \
	    bundle clean --force && \
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

# Install assets
# Notes: For an app using encrypted credentials, Rails raises a `MissingKeyError`
#        if the master key is missing. Because on CI there is no master key,
#        we hide the credentials while compiling assets.
ONBUILD COPY package.json yarn.lock* /app/
ONBUILD RUN mv config/credentials.yml.enc config/credentials.yml.enc.bak 2>/dev/null || true
ONBUILD RUN bundle exec rails assets:precompile SECRET_KEY_BASE=X RAILS_MASTER_KEY=X 
ONBUILD RUN mv config/credentials.yml.enc.bak config/credentials.yml.enc 2>/dev/null || true

# Copy the whole application folder into the image
ONBUILD COPY . /app
