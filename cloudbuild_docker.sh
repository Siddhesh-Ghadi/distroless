#!/bin/sh

set -o errexit
set -o xtrace

# Publish manifest lists second, after all of the binary material
# has been uploaded, so that it is fast.  We want fast because enabling
# the experimental features in docker changes ~/.docker/config.json, which
# GCB periodically tramples.
#
# Enable support for 'docker manifest create'
# https://docs.docker.com/engine/reference/commandline/manifest_create/
sed -i 's/^{/{"experimental": "enabled",/g' ~/.docker/config.json

docker_manifest() {
  _image=$1
  _archs=$2
  _from_images=""

  for arch in $_archs; do
    _from_images="$_from_images $_image-$arch"
  done

  docker manifest create $_image $_from_images
  docker manifest push --amend $_image
}

for distro_suffix in "" -debian9 -debian10; do
  docker_manifest $PROJECT_ID/static${distro_suffix}:nonroot "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/static${distro_suffix}:latest "amd64 arm arm64 s390x ppc64le"

  docker_manifest $PROJECT_ID/base${distro_suffix}:nonroot "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/base${distro_suffix}:latest "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/base${distro_suffix}:debug-nonroot "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/base${distro_suffix}:debug "amd64 arm arm64 s390x ppc64le"

  docker_manifest $PROJECT_ID/cc${distro_suffix}:nonroot "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/cc${distro_suffix}:latest "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/cc${distro_suffix}:debug-nonroot "amd64 arm arm64 s390x ppc64le"
  docker_manifest $PROJECT_ID/cc${distro_suffix}:debug "amd64 arm arm64 s390x ppc64le"

  docker_manifest $PROJECT_ID/python2.7${distro_suffix}:latest "amd64 arm64"
  docker_manifest $PROJECT_ID/python2.7${distro_suffix}:debug "amd64 arm64"

  docker_manifest $PROJECT_ID/python3${distro_suffix}:nonroot "amd64 arm64"
  docker_manifest $PROJECT_ID/python3${distro_suffix}:latest "amd64 arm64"
  docker_manifest $PROJECT_ID/python3${distro_suffix}:debug-nonroot "amd64 arm64"
  docker_manifest $PROJECT_ID/python3${distro_suffix}:debug "amd64 arm64"
done

docker manifest create $PROJECT_ID/nodejs:latest \
   $PROJECT_ID/nodejs:latest-amd64 \
   $PROJECT_ID/nodejs:latest-arm64
docker manifest push --amend $PROJECT_ID/nodejs:latest

docker manifest create $PROJECT_ID/nodejs:debug \
   $PROJECT_ID/nodejs:debug-amd64 \
   $PROJECT_ID/nodejs:debug-arm64
docker manifest push --amend  $PROJECT_ID/nodejs:debug
