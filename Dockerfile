FROM ruby:3.2.3

# Install packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Create a directory for the application
RUN mkdir /rails-application

# Set working directory to /rails-application
WORKDIR /rails-application

# Copy the Gemfile and Gemfile.lock into the image
COPY Gemfile Gemfile.lock /rails-application/

# Install bundle
RUN bundle install

# Copy the whole application to /rails-application
COPY . /rails-application/
