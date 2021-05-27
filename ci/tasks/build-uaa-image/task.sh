#!/bin/bash
set -euo pipefail

trap "pkill dockerd" EXIT

start-docker &
echo 'until docker info; do sleep 5; done' >/usr/local/bin/wait_for_docker
chmod +x /usr/local/bin/wait_for_docker
timeout 300 wait_for_docker

<<<"$DOCKERHUB_PASSWORD" docker login --username "$DOCKERHUB_USERNAME" --password-stdin

pushd uaa-k8s-release/build > /dev/null
  ./build.sh
  uaa_image_ref="$(yq -r '.overrides[] | select(.image | test("/uaa@")).newImage' kbld.lock.yml)"
popd > /dev/null

docker pull "$uaa_image_ref"
docker save "$uaa_image_ref" -o kbld-output/image.tar
