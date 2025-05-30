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
RUN apt-get update && \
  apt-get install -y build-essential devscripts equivs quilt dh-make automake wget software-properties-common

# NOTE: Directly specifying the repository in `add-apt-repository` is deprecated
# with add-apt-repository 0.99.x. The parameter `--sourceslist` should be used instead.
# However, Focal still comes with version 0.98 which doesn't support that parameter,
# so we stick with the deprecated line for now.
RUN wget -qO - http://linux.lsdev.sil.org/downloads/sil-testing.gpg > /etc/apt/trusted.gpg.d/linux-lsdev-sil-org.asc ; \
  wget -qO - https://packages.sil.org/keys/pso-keyring-2016.gpg > /etc/apt/trusted.gpg.d/pso-keyring-2016.gpg ; \
  ${ENABLE_LLSO} && add-apt-repository --yes --no-update "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc) main" ; \
  ${ENABLE_LLSO} && add-apt-repository --yes --no-update "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc)-experimental main" ; \
  ${ENABLE_PSO} && add-apt-repository --yes --no-update "deb http://packages.sil.org/ubuntu $(lsb_release -sc) main" ; \
  ${ENABLE_PSO} && add-apt-repository --yes --no-update "deb http://packages.sil.org/ubuntu $(lsb_release -sc)-experimental main" ; \
  apt-get update

COPY build-package.sh /build-package.sh

ENTRYPOINT ["/build-package.sh"]
