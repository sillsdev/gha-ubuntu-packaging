# syntax=docker/dockerfile:1
ARG DIST=latest
ARG DISTRIBUTION=ubuntu
ARG PLATFORM=amd64
ARG ENABLE_LLSO=true
ARG ENABLE_PSO=true
FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}:${DIST}

# Make ARGS available to the build environment -
# see https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG DIST
ARG DISTRIBUTION
ARG PLATFORM
ARG ENABLE_LLSO
ARG ENABLE_PSO

# set the environment variables that gha sets
ENV INPUT_DISTRIBUTION="${DISTRIBUTION}"
ENV INPUT_DIST="${DIST}"
ENV INPUT_PLATFORM="${PLATFORM}"
ENV INPUT_RESULT_DIR="artifacts"
ENV INPUT_ENABLE_LLSO="${ENABLE_LLSO}"
ENV INPUT_ENABLE_PSO="${ENABLE_PSO}"
ENV INPUT_DEB_FULLNAME="SIL GHA Packager"
ENV INPUT_DEB_EMAIL="undelivered@sil.org"
ENV INPUT_PRERELEASE_TAG=""

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes

# Installing the build environment
COPY install-build-env.sh /install-build-env.sh
RUN /install-build-env.sh && \
  rm /install-build-env.sh

COPY build-package.sh /build-package.sh

ENTRYPOINT ["/build-package.sh"]
