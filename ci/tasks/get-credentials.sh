#!/usr/bin/env bash

set -euo pipefail

workspace_dir=$(pwd)

pushd "${workspace_dir}/${BBL_STATE_DIR}"
    eval "$(bbl print-env)"
    env_name=$(bbl env-id)
    cred_name="/bosh-${env_name}/${CREDENTIAL_NAME}"
    echo "Getting credential ${cred_name}"
    credhub get --name="${cred_name}" --output-json | jq ".value" -r > "${workspace_dir}/credential/value"
popd
