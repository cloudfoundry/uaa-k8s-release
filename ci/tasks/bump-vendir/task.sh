#!/bin/bash

tag="$(cat github-release/tag)"
pushd component/build > /dev/null
  sed -i "s|ref:.*|ref: $tag|" vendir.yml
popd > /dev/null

cp -r component/* updated-component
