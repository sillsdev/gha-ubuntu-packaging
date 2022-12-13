#!/bin/bash -l

set -eu

if (( $# < 6 )); then
	echo "Missing parameter!"
	echo "Usage: $0 <dist> <.dsc file> <source_dir> <result_dir> <debfullname> <debemail>"
	exit 1
fi

WORK_DIR="$(pwd)"
BUILD_DIR=/build

# Process parameters
DIST=$1
DSC=$2
SOURCE_DIR=$WORK_DIR/$3
RESULT_DIR=$WORK_DIR/$4
DEBFULLNAME=$5
DEBEMAIL=$6

export DEBFULLNAME
export DEBEMAIL

# Extract source
cd "$SOURCE_DIR"
echo "Extracting source"
dpkg-source --extract "$DSC" "$BUILD_DIR"

# Install build dependencies
cd "$BUILD_DIR"
apt update
echo "Installing build dependencies"
mk-build-deps --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' debian/control

# Build binary package
echo "Updating version"
dch --local "+${DIST}" --distribution "$DIST" ""

echo "Creating binary package"
dpkg-buildpackage --build=any,all --unsigned-source --unsigned-changes

echo "Copying artifacts"
cd ..
mkdir -p "$RESULT_DIR"
cp ./*.deb "$RESULT_DIR"
cp ./*.ddeb "$RESULT_DIR"
cp ./*.changes "$RESULT_DIR"
cp ./*.buildinfo "$RESULT_DIR"
