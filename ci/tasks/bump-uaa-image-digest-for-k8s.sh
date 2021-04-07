#!/usr/bin/env bash

set -eu

DIGEST=""
REPOSITORY=""
pushd docker-image-cloudfoundry-uaa
  DIGEST=$(cat ./digest)
  REPOSITORY=$(cat ./repository)
popd

echo "DIGEST=${DIGEST}"
echo "REPOSITORY=${REPOSITORY}"
IMAGE="${REPOSITORY}@${DIGEST}"

TEMP=$(mktemp)
cat <<-EOF > "${TEMP}"
#@data/values
---
image: "${IMAGE}"
EOF

cp --recursive uaa/. bumped-uaa/
mv "${TEMP}" bumped-uaa/k8s/templates/values/image.yml
echo "new image.yml"
cat bumped-uaa/k8s/templates/values/image.yml

pushd bumped-uaa
  git config --global user.email "cf-identity-eng@pivotal.io"
  git config --global user.name "Cloud Foundry Identity Team"
  git add -A
  git commit -m "Update UAA image reference in k8s deployment template to ${IMAGE}"
popd