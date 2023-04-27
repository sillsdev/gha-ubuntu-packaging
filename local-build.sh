#!/bin/bash

show_usage()
{
  echo ""
  echo "Usage:   $0 DIST DSC"
  echo ""
  echo "Example: ./local-build.sh jammy path/to/ibus_1.5.28-3sil1~jammy.dsc"
  exit "$1"
}

if [ "$1" == "--help" ]; then
  show_usage 0
fi

if [[ $# -ne 2 ]]; then
  show_usage 1
fi

DIST="$1"
DSC="$(basename "$2")"
DSC_DIR="$(readlink -f "$(dirname "$2")")"

SCRIPT_DIR="$(readlink -f "$(dirname "$0")")"
IMAGE_NAME="sillsdev/${DIST}"

cd "$SCRIPT_DIR" || exit

IMAGE_ID=$(docker images --quiet "${IMAGE_NAME}")

if [ -z "$IMAGE_ID" ]; then
  echo -e "\e[0;35mBuilding docker image for ${DIST}\e[0m"
  docker build --build-arg DIST="${DIST}" --build-arg PLATFORM=amd64 -t "${IMAGE_NAME}" .
fi

cd "${DSC_DIR}" || exit
echo -e "\e[0;35mBuilding binary image for ${DIST}\e[0m"
docker run -v "$(pwd)":/source -i -t -w /source --platform=linux/amd64 \
    "${IMAGE_NAME}" "${DIST}" "${DSC}" .
