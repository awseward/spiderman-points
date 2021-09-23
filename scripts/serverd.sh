#!/usr/bin/env bash

set -euo pipefail

ru_port=${PORT:-4567}
ru_server="${SERVER:-puma}"

bundle exec rackup --server "${ru_server}" --port "${ru_port}" --daemonize --pid "$1" config.ru
