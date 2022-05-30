#!/usr/bin/env bash

docker run --rm -ti -w /work -v "$(pwd):/work" ghcr.io/stephenc/docker-science-data-reporting:v1.3.0 "$@"
