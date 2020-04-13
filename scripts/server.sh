#!/usr/bin/env bash

set -euo pipefail

app_port=${PORT:-4567}

bundle exec rackup -p "${app_port}" config.ru
