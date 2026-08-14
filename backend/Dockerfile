# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.11
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"


# Throw-away build stage to reduce size of final image
FROM base AS build

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# assets:precompile は RAILS_ENV=production で boot するため、本番で fail-fast する
# 設定（cdn.rb / cors.rb の ENV.fetch、storage.yml の s3_prod）がすべて評価される。
# ビルド時には実際の値を渡せないので、ここではダミーを与えて boot だけ通す。
# 値の検証は実行時（コンテナ起動時）の同じ ENV.fetch が担う。
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 \
    CLOUDFRONT_BASE_URL=https://dummy \
    FRONTEND_ORIGIN=https://dummy \
    AWS_ACCESS_KEY_ID=dummy \
    AWS_SECRET_ACCESS_KEY=dummy \
    AWS_BUCKET=dummy-bucket \
    ./bin/rails assets:precompile


# Final stage for app image
FROM base

# hadolint ignore=DL3008
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
