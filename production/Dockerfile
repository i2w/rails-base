ARG RUBY_VERSION
FROM i2wdev/ruby-base:$RUBY_VERSION

LABEL maintainer="ian@i2w.me"
LABEL RUBY_VERSION=$RUBY_VERSION

ENV APK_LIST file \
             musl-locales \
             postgresql-client \
             tzdata

# Install edge repositories and our APK_LIST, cleanup
RUN apk upgrade -U -a && \
    apk add --no-cache $APK_LIST && \
    rm -rf /var/cache/* && mkdir /var/cache/apk

# Configure Rails
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
WORKDIR /app
EXPOSE 3000

ARG RAILS_VERSION
ARG DEPS_VERSION
LABEL RAILS_VERSION=$RAILS_VERSION
LABEL DEPS_VERSION=$DEPS_VERSION

# Install Apkfile packages
ONBUILD COPY Apkfile /app/Apkfile
ONBUILD RUN apk add $(cat /app/Apkfile | xargs) && \
            rm -rf /var/cache/* && mkdir /var/cache/apk

# Copy gems from builder stage, set without test and development, remove the rest
ONBUILD COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config set without 'test development' && \
            bundle clean --force

# Copy app from builder stage
ONBUILD COPY --from=builder /app /app

# Remove folders not needed in resulting image
ONBUILD RUN rm -rf node_modules tmp/cache vendor/bundle test spec
