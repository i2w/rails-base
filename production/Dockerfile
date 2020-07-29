FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
        postgresql-client \
        tzdata \
        file

# Configure Rails and entry point
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
WORKDIR /app
EXPOSE 3000
CMD ["bin/rails", "server"]

# Write GIT commit SHA and TIME to env vars
ONBUILD ARG COMMIT_SHA
ONBUILD ARG COMMIT_TIME
ONBUILD ENV COMMIT_SHA ${COMMIT_SHA}
ONBUILD ENV COMMIT_TIME ${COMMIT_TIME}

# Install Apkfile packages
ONBUILD RUN touch /tmp/Apkfile
ONBUILD COPY Apkfile* /tmp
ONBUILD RUN apk add --no-cache $(cat /tmp/Apkfile | xargs)

# Copy gems from builder stage, install only production, remove the rest
ONBUILD COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config set without 'test development' && \
            bundle install -j4 --retry 3 && \
	    bundle clean --force

# Copy app from builder stage
ONBUILD COPY --from=builder /app /app

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec
