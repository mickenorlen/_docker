ARG PARENT_IMAGE

FROM $PARENT_IMAGE

RUN apk add --update \
	build-base \
  libxml2-dev \
  libxslt-dev \
	tzdata \
  postgresql-dev \
	nodejs \
	postgresql-client \
	bash \
	vim \
	&& rm -rf /var/cache/apk/*

# Use libxml2, libxslt packages from alpine for building nokogiri
# https://github.com/gliderlabs/docker-alpine/issues/53#issuecomment-179486583
RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /app /home/docker


# If using much larger non-alpine parent
# FROM ruby:2.5
# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim
# RUN mkdir /app /home/docker
