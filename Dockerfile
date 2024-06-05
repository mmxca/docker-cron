# we need to copy from docker image the docker exec

# and we need to install cron

ARG DOCKER_IMAGE_TAG=latest
ARG ALPINE_IMAGE_TAG=latest
ARG CURL_IMAGE_TAG=latest

FROM docker:${DOCKER_IMAGE_TAG}

FROM alpine:${ALPINE_IMAGE_TAG}

FROM curlimages/curl:${CURL_IMAGE_TAG}

ENV DOCKER_CRONTAB=''

#copy curl
COPY --from=curlimages/curl:latest /usr/bin/curl /usr/bin/

#copy docker
COPY --from=0 /usr/local/bin/docker /usr/local/bin/docker

#copy docker-compose
COPY --from=docker/compose:1.25.0-alpine /usr/local/bin/docker-compose /usr/local/bin/

#copy entrypoint
COPY docker-entrypoint.sh /

WORKDIR /cron-env

ENTRYPOINT /docker-entrypoint.sh
