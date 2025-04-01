# syntax=docker/dockerfile:1
ARG DIST=latest
ARG DISTRIBUTION=ubuntu
ARG PLATFORM=amd64
FROM --platform=linux/${PLATFORM} ${DISTRIBUTION}:${DIST}
# Set the env variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_PRIORITY=critical
ENV DEBCONF_NOWARNINGS=yes
# Installing the build environment
RUN apt-get update && \
  apt-get install -y build-essential devscripts equivs quilt dh-make automake wget software-properties-common python3-setuptools debhelper dpkg-dev python3-dev python3-pip sudo

RUN useradd -ms /bin/bash -G sudo docker && mkdir /source && chown docker /source

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker

# set the environment variables that gha sets
ENV DEB_FULLNAME="ICANN-DNS GHA Packager"
ENV DEBEMAIL="noc@dns.icann.org"



ENTRYPOINT ["/bin/bash"]
