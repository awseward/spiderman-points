#!/usr/bin/env bash

set -euo pipefail

while read -r line; do
  # shellcheck disable=SC2086
  asdf install ${line}
done < .tool-versions

gem install bundler
bundle install

