FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
        postgresql-client \
        nodejs \
        yarn \
        tzdata \
        file

ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true

WORKDIR /app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]

ONBUILD COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Install all gems, and cleanup
ONBUILD COPY Gemfile /app
ONBUILD COPY Gemfile.lock /app
ONBUILD RUN bundle install -j4 --retry 3 && \
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

ONBUILD COPY --from=builder /app /app

# Copy the whole application folder into the image
ONBUILD COPY . /app

