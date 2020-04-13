#!/usr/bin/env bash

set -euo pipefail

find .  -type f -name '*.rb' -or -name '*.ru' | entr -r ./scripts/server.sh
