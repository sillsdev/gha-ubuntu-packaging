#!/bin/bash -l

set -eu

WORK_DIR=$(pwd)
BUILD_DIR=/build

DIST=${INPUT_DIST}
DSC=${INPUT_SOURCEPACKAGE:-}
SOURCE_DIR=${WORK_DIR}/${INPUT_SOURCE_DIR:-.}
RESULT_DIR=${WORK_DIR}/${INPUT_RESULT_DIR:-artifacts}
DEBFULLNAME=${INPUT_DEB_FULLNAME:-SIL GHA Packager}
DEBEMAIL=${INPUT_DEB_EMAIL:-undelivered@sil.org}
PRERELEASE_TAG=${INPUT_PRERELEASE_TAG:-}

export DEBFULLNAME
export DEBEMAIL

COLOR_GREEN='\e[0;32m'

startgroup()
{
    echo -e "::group::${COLOR_GREEN}$1"
}

endgroup()
{
    echo "::endgroup::"
}

# Extract source
cd "$SOURCE_DIR"
startgroup "Extracting source"
dpkg-source --extract "$DSC" "$BUILD_DIR"
endgroup

# Install build dependencies
pushd "$BUILD_DIR"
apt update
startgroup "Installing build dependencies"
mk-build-deps --install --tool='apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' debian/control
endgroup

# Build binary package
startgroup "Updating version"
dch --local "${PRERELEASE_TAG}+${DIST}" --distribution "$DIST" "Release to ${DIST}"
endgroup

startgroup "Creating binary package"
dpkg-buildpackage --build=any,all --unsigned-source --unsigned-changes
endgroup

startgroup "Copying artifacts"
cd ..
mkdir -p "$RESULT_DIR"
cp ./*.deb "$RESULT_DIR" || true
cp ./*.ddeb "$RESULT_DIR" || true
cp ./*.changes "$RESULT_DIR" || true
cp ./*.buildinfo "$RESULT_DIR" || true
endgroup
