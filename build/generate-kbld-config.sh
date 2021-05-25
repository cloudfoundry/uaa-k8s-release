#! /bin/bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function generate_kbld_config() {
  local kbld_config_path="${1}"

  local source_path
  source_path="${SCRIPT_DIR}/sources/uaa"

  pushd "${source_path}" > /dev/null
    local git_ref
    git_ref=$(git rev-parse HEAD)
    version=$(git tag --points-at ${git_ref} | head -1 | sed 's/^v//')

    if [ -z "$version" ]
    then
      version="0.0.0"
    fi
  popd > /dev/null

  echo "Creating UAA kbld config with ytt"
  local kbld_config_values
  # Note: uaa-k8s-release also generates its own version of these data values
  # if we change the values schema here we will need to change it there as well
  kbld_config_values=$(cat <<EOF
#@data/values
---
git_ref: ${git_ref}
git_url: https://github.com/cloudfoundry/uaa-k8s-release
version: ${version}
EOF
)

  echo "${kbld_config_values}" | ytt -f "${SCRIPT_DIR}/kbld.yml" -f - > "${kbld_config_path}"
}

function main() {
  local kbld_config_path="${1}"

  generate_kbld_config "${kbld_config_path}"
}

main "$@"
