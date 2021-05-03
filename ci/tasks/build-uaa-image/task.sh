#!/bin/bash
set -euo pipefail

trap "pkill dockerd" EXIT

start-docker &
echo 'until docker info; do sleep 5; done' >/usr/local/bin/wait_for_docker
chmod +x /usr/local/bin/wait_for_docker
timeout 300 wait_for_docker

<<<"$DOCKERHUB_PASSWORD" docker login --username "$DOCKERHUB_USERNAME" --password-stdin

mkdir -p sources/uaa
tar xf uaa-github-release/source.tar.gz --directory sources/uaa --strip-components=1

git_ref="$(cat uaa-github-release/commit_sha)"
version="$(cat uaa-github-release/version)"
kbld_config_values=$(cat <<EOF
#@data/values
---
git_ref: ${git_ref}
git_url: https://github.com/cloudfoundry/uaa-k8s-release
version: ${version}
EOF
)
kbld_config="$(echo "${kbld_config_values}" | ytt -f "cf-for-k8s/images/build/uaa/kbld.yml" -f -)"

kbld -f <(echo "$kbld_config") \
    -f <(ytt -f "cf-for-k8s/config/" -f "cf-for-k8s/sample-cf-install-values.yml") \
    --lock-output kbld-output/kbld.lock.yml > /dev/null

uaa_image_ref="$(yq -r '.overrides[] | select(.image | test("/uaa@")).newImage' kbld-output/kbld.lock.yml)"
docker pull "$uaa_image_ref"
docker save "$uaa_image_ref" -o kbld-output/image.tar
