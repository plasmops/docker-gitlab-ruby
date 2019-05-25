ARG tag
FROM ruby:${tag}-alpine

ARG version
LABEL com.plasmops.vendor=PlasmOps \
      com.plasmops.version=$version \
      com.plasmops.ci=gitlab

ENV LANG=C.UTF-8

# Docker env variables
ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.09.0
ENV DOCKER_SHASUM 08795696e852328d66753963249f4396af2295a7fe2847b839f7102e25e47cb9

## Install build software
#
RUN apk add --no-cache --update \
        curl bash git tar jq \
        git binutils coreutils findutils file build-base

## AWS tools
RUN \
    pip install awscli && apk add --no-cache groff less mailcap && \
    ( rm -rf /root/.cache /root/.* 2>/dev/null || /bin/true )

## Install docker-ce
#
RUN \
  if ! curl -#fL -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz"; then \
    echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for x86_64"; \
    exit 1; \
  fi; \
  \
  tar -xzf docker.tgz \
    --strip-components 1 \
    -C /usr/local/bin && \
  \
  echo "${DOCKER_SHASUM}  docker.tgz" | sha256sum -c && rm docker.tgz
## We don't install custom modprobe, since haven't run into issues yet (see the link bellow)
#  https://github.com/docker-library/docker/blob/master/18.06/modprobe.sh
#

## Install nodejs
#
RUN apk add --no-cache --update \
        nodejs g++ make

COPY /entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
