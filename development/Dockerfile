FROM ruby:2.6.6-alpine
LABEL maintainer="ian@i2w.me"

# Add basic packages for use in development and testing
RUN apk add --no-cache \
        postgresql-client \
        vips \
	chromium-chromedriver \
	chromium \
        nodejs \
	yarn \
        tzdata \
        file

# Configure rails and entry point 
ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true
WORKDIR /app
EXPOSE 3000
CMD ["bin/rails", "server"]

# Copy our bundle and application from builder
ONBUILD COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
ONBUILD COPY --from=builder /app /app

