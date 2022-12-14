# syntax=docker/dockerfile:1
ARG DIST=latest
ARG DISTRIBUTION=ubuntu
ARG PLATFORM=amd64
ARG ENABLE_LLSO=true
ARG ENABLE_PSO=true
FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}:${DIST}

# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes

# Installing the build environment
RUN apt-get update && \
	apt-get install -y build-essential devscripts equivs quilt dh-make automake wget software-properties-common

# NOTE: Directly specifying the repository in `add-apt-repository` is deprecated.
# The parameter `--sourceslist` should be used instead. However, Bionic doesn't
# have a version that supports that parameter, so we stick with the deprecated
# line for now.
RUN wget -qO - http://linux.lsdev.sil.org/downloads/sil-testing.gpg > /etc/apt/trusted.gpg.d/linux-lsdev-sil-org.asc ; \
	wget -qO - https://packages.sil.org/keys/pso-keyring-2016.gpg > /etc/apt/trusted.gpg.d/pso-keyring-2016.gpg ; \
	${ENABLE_LLSO} && add-apt-repository --yes --no-update "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc) main" ; \
	${ENABLE_LLSO} && add-apt-repository --yes --no-update "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc)-experimental main" ; \
	${ENABLE_PSO} && add-apt-repository --yes --no-update "deb http://packages.sil.org/ubuntu $(lsb_release -sc) main" ; \
	${ENABLE_PSO} && add-apt-repository --yes --no-update "deb http://packages.sil.org/ubuntu $(lsb_release -sc)-experimental main" ; \
	apt-get update

COPY build-package.sh /build-package.sh

ENTRYPOINT ["/build-package.sh"]