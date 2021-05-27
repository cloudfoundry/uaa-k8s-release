#!/bin/bash

version="$(cat github-release/version)"
pushd component/build > /dev/null
  sed -i "s|ref:.*|ref: $version|" vendir.yml
popd > /dev/null

cp -r component/* updated-component
