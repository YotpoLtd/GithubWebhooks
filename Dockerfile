FROM ruby:2.5

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN mkdir /githubwebhooks
WORKDIR /githubwebhooks
COPY Gemfile /githubwebhooks/Gemfile
COPY Gemfile.lock /githubwebhooks/Gemfile.lock
RUN bundle install
COPY . /githubwebhooks