#!/bin/sh -ex

ARTEMIS_VERSION=$(head -n 1 VERSION.txt)
VERSION_ALPINE=$(head -n 1 VERSION-alpine.txt)
VERSION_TEMURIN=$(head -n 1 VERSION-temurin.txt)

ARTEMIS_DIRECTORY_NAME="apache-artemis-${ARTEMIS_VERSION}"
ARTEMIS_TARBALL_NAME="apache-artemis-${ARTEMIS_VERSION}-bin.tar.gz"
ARTEMIS_SIGNATURE_NAME="apache-artemis-${ARTEMIS_VERSION}-bin.tar.gz.asc"

wget -c "https://downloads.apache.org/activemq/KEYS"
wget -c "https://downloads.apache.org/activemq/activemq-artemis/${ARTEMIS_VERSION}/${ARTEMIS_SIGNATURE_NAME}"
wget -c "https://downloads.apache.org/activemq/activemq-artemis/${ARTEMIS_VERSION}/${ARTEMIS_TARBALL_NAME}"

gpg --import KEYS
gpg --verify "${ARTEMIS_SIGNATURE_NAME}"

rm -rfv build
mkdir -p build
cd build

tar xvf "../${ARTEMIS_TARBALL_NAME}"
mv "${ARTEMIS_DIRECTORY_NAME}" "artemis"
cp ../Containerfile .
cp ../broker.sh .
chmod 755 broker.sh

podman build \
--format docker \
--build-arg "version=${ARTEMIS_VERSION}" \
--build-arg "version_alpine=${VERSION_ALPINE}" \
--build-arg "version_temurin=${VERSION_TEMURIN}" \
--iidfile "../image-id.txt" \
-t "quay.io/io7mcom/adelaide:${ARTEMIS_VERSION}" .
