FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim
RUN mkdir /app /home/docker
