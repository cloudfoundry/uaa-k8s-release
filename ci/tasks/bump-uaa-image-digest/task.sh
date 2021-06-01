#!/bin/bash
set -euo pipefail

function get_image_digest_for_resource () {
  pushd "$1" >/dev/null
    cat digest
  popd >/dev/null
}

UAA_IMAGE="cloudfoundry/uaa@$(get_image_digest_for_resource uaa-docker-image)"
STATSD_EXPORTER_IMAGE="cloudfoundry/statsd_exporter-cf-for-k8s@$(get_image_digest_for_resource statsd-exporter-docker-image)"

echo "Updating uaa image to digest: ${UAA_IMAGE}"
echo "Updating statsd_exporter image to digest: ${STATSD_EXPORTER_IMAGE}"

cat <<- EOF > "${PWD}/update-images.yml"
---
- type: replace
  path: /images/uaa
  value: ${UAA_IMAGE}
- type: replace
  path: /images/statsd_exporter
  value: ${STATSD_EXPORTER_IMAGE}
EOF

pushd "uaa-k8s-release"
bosh interpolate config/values/images.yml -o "../update-images.yml" > values-int.yml

cat <<- EOF > config/values/images.yml
#@ load("@ytt:overlay", "overlay")
#@data/values
---
#@overlay/match missing_ok=True
EOF

cat values-int.yml >> config/values/images.yml
popd


pushd "uaa-k8s-release"
git config user.name "${GIT_COMMIT_USERNAME}"
git config user.email "${GIT_COMMIT_EMAIL}"

git add build/vendir.yml
git add build/vendir.lock.yml
git add config/values/images.yml

# dont make a commit if there aren't new images
if ! git diff --cached --exit-code; then
  echo "committing!"
  git commit -m "images.yml updated by CI"
else
  echo "no changes to images, not bothering with a commit"
fi
popd

cp -R uaa-k8s-release/. updated-uaa-k8s-release/
