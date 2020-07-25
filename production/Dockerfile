FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
        postgresql-client \
        tzdata \
        file

# Configure Rails
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

WORKDIR /app
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-p", "3000", "-b", "0.0.0.0"]

# Write GIT commit SHA and TIME to env vars
ONBUILD ARG COMMIT_SHA
ONBUILD ARG COMMIT_TIME

ONBUILD ENV COMMIT_SHA ${COMMIT_SHA}
ONBUILD ENV COMMIT_TIME ${COMMIT_TIME}

# Add user
ONBUILD RUN addgroup -g 1000 -S app && \
            adduser -u 1000 -S app -G app

# Copy app with gems from former build stage
ONBUILD COPY --from=builder --chown=app:app /usr/local/bundle/ /usr/local/bundle/

# Install app gems (production only), remove unneeded ones, and cleanup
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config --local without 'development test' && \
            bundle install -j4 --retry 3 && \
            bundle clean --force && \
            rm -rf /usr/local/bundle/cache/*.gem && \
            find /usr/local/bundle/gems/ -name "*.c" -delete && \
            find /usr/local/bundle/gems/ -name "*.o" -delete

ONBUILD COPY --from=builder --chown=app:app /app /app

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec

ONBUILD USER app

