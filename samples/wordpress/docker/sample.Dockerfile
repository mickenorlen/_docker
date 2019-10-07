ARG PARENT_IMAGE

FROM $PARENT_IMAGE

RUN apt-get update && apt-get install -y vim
