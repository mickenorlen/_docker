ARG PARENT_IMAGE

FROM $PARENT_IMAGE

# RUN apk add --update \
# 	build-base \
#   libxml2-dev \
#   libxslt-dev \
# 	tzdata \
#   postgresql-dev \
# 	nodejs \
# 	yarn \
# 	postgresql-client \
# 	bash \
# 	vim \
# 	&& rm -rf /var/cache/apk/*

# # Use libxml2, libxslt packages from alpine for building nokogiri
# # https://github.com/gliderlabs/docker-alpine/issues/53#issuecomment-179486583
# RUN bundle config build.nokogiri --use-system-libraries

# RUN mkdir /app


# If using much larger non-alpine parent
# FROM ruby:2.5
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim yarn
RUN mkdir /app /home/docker
