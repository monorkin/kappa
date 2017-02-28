FROM ruby:2.3

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

RUN mkdir -p runner
WORKDIR /usr/src/app/runner
COPY runner/Gemfile* ./
RUN bundle install

RUN mkdir -p configurator
WORKDIR /usr/src/app/configurator
COPY configurator/Gemfile* ./
RUN bundle install

WORKDIR /usr/src/app
COPY . .

# WORKDIR /usr/src/app/runner
# RUN bundle exec rake assets:precompile

# WORKDIR /usr/src/app/configurator
# RUN bundle exec rake assets:precompile

WORKDIR /usr/src/app
EXPOSE 80 8080
CMD "./start.sh"
