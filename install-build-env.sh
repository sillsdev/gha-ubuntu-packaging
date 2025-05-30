#!/bin/bash
set -eu

retry() {
  local count=$1
  shift
  local wait=1
  for ((i=0; i<count; i++)); do
    "$@" && return 0
    echo "Command failed, retrying in ${wait} seconds..."
    sleep ${wait}
  done
  echo "Command failed after ${count} attempts."
  return 1
}

retry 5 apt-get update
retry 5 apt-get install -y build-essential devscripts equivs quilt \
  dh-make automake wget software-properties-common retry

retry 5 wget -qO - http://linux.lsdev.sil.org/downloads/sil-testing.gpg > /etc/apt/trusted.gpg.d/linux-lsdev-sil-org.asc
retry 5 wget -qO - https://packages.sil.org/keys/pso-keyring-2016.gpg > /etc/apt/trusted.gpg.d/pso-keyring-2016.gpg

${ENABLE_LLSO} && add-apt-repository --yes --no-update --sourceslist "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc) main"
${ENABLE_LLSO} && add-apt-repository --yes --no-update --sourceslist "deb http://linux.lsdev.sil.org/ubuntu $(lsb_release -sc)-experimental main"
${ENABLE_PSO} && add-apt-repository --yes --no-update --sourceslist "deb http://packages.sil.org/ubuntu $(lsb_release -sc) main"
${ENABLE_PSO} && add-apt-repository --yes --no-update --sourceslist "deb http://packages.sil.org/ubuntu $(lsb_release -sc)-experimental main"

retry 5 apt-get update
