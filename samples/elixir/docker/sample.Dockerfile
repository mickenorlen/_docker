ARG PARENT_IMAGE

FROM $PARENT_IMAGE

RUN apk add --update \
  postgresql-client \
  nodejs \
  bash \
  vim \
  yarn \
  && rm -rf /var/cache/apk/*

# Fix paths
RUN mkdir /app /home/docker

