# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.7
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# --- 1. Packages de base ---
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl build-essential libjemalloc2 git nodejs yarn libyaml-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# --- 2. ENV pour production ---
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# --- 3. Phase de build ---
FROM base AS build

# Installer bundler
RUN gem update --system && \
    gem install --no-document bundler -v '~> 2.6'\

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# Ajouter le code source
COPY . .

# Bootsnap & assets
RUN bundle exec bootsnap precompile app/ lib/


# Précompile les assets sans secrets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
RUN RAILS_ENV=production bundle exec rails webpacker:compile
RUN SECRET_KEY_BASE=1 ./bin/rails assets:clean

# --- 4. Image finale ---
FROM base

# Foreman uniquement à runtime
RUN gem install foreman --no-document

COPY --from=build /rails /rails
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"

# Utilisateur non-root
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails log tmp
USER 1000:1000

# Point d'entrée
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Le load balancer redirige vers ce port
EXPOSE 3000

# Foreman gère Rails + Webpacker
CMD ["foreman", "start"]
