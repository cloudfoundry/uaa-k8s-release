#!/bin/bash

set -eux

pushd uaa/k8s
    make test
popd