#!/bin/bash

set -eux

pushd uaa-k8s-release/
    make test
popd
