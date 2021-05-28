#!/bin/bash

tag="$(cat github-release/tag)"
echo "Updating vendir.yml to use ${tag}"
pushd component/build > /dev/null
  sed -i "s|ref:.*|ref: $tag|" vendir.yml
popd > /dev/null

cp -R component/. updated-component
