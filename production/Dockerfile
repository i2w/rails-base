FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

ENV APK_LIST file \
             musl-locales \
             postgresql-client \
             tzdata

# Install edge repositories and our APK_LIST, cleanup
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/main" >> /etc/apk/repositories && \
    apk upgrade -U -a && \
    apk add --no-cache $APK_LIST && \
    rm -rf /var/cache/* && mkdir /var/cache/apk

# Configure Rails
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
WORKDIR /app
EXPOSE 3000

# Write GIT commit SHA and TIME to env vars
ONBUILD ARG COMMIT_SHA
ONBUILD ARG COMMIT_TIME
ONBUILD ENV COMMIT_SHA ${COMMIT_SHA}
ONBUILD ENV COMMIT_TIME ${COMMIT_TIME}

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
