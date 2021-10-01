#!/usr/bin/env bash

set -euo pipefail

readonly wd="${1:?}"
readonly app_env="${2:?}"

# shellcheck disable=SC1090
cd "${wd}" && . "${app_env}" && ./scripts/server.sh
