ARG PARENT_IMAGE

FROM $PARENT_IMAGE





# create destination directory
# RUN mkdir -p /usr/src/nuxt-app
# WORKDIR /usr/src/nuxt-app

# # update and install dependency
# RUN apk update && apk upgrade
# RUN apk add git

# # copy the app, note .dockerignore
# COPY . /usr/src/nuxt-app/
# RUN npm install

# # build necessary, even if no static files are needed,
# # since it builds the server as well
# RUN npm run build

# # expose 5000 on container
# EXPOSE 5000

# # set app serving to permissive / assigned
# ENV NUXT_HOST=0.0.0.0
# # set app port
# ENV NUXT_PORT=5000

# # start the app
# CMD [ "npm", "start" ]




RUN apk add --no-cache --update \
	python \
	make \
	g++ \
	yarn \
	bash \
	vim \
	&& rm -rf /var/cache/apk/*

# Use libxml2, libxslt packages from alpine for building nokogiri
# https://github.com/gliderlabs/docker-alpine/issues/53#issuecomment-179486583
# RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir /app


# If using much larger non-alpine parent
# FROM ruby:2.5
# RUN apt-get update -qq && apt-get install -y nodejs postgresql-client vim
# RUN mkdir /app /home/docker
