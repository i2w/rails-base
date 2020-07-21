FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages
RUN apk add --no-cache \
      postgresql-client \
      tzdata \
      file

# Configure Rails
ENV RAILS_ENV development

WORKDIR /app

# Expose Puma port
EXPOSE 3000

# Add user
ONBUILD RUN addgroup -g 1000 -S app && \
            adduser -u 1000 -S app -G app

# Install Ruby gems (for development)
ONBUILD COPY Gemfile* /app/
ONBUILD RUN bundle config --local without 'test' && \
            bundle install -j4 --retry 3

ONBUILD COPY --from=Builder --chown=app:app /app /app
