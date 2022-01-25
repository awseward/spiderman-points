#!/usr/bin/env bash

set -euo pipefail

html() {
  umask 022
  xargs -t dhall text --file "$1.dhall" --output <<< "$1.html"
}

html_all() {
  local -r pages=(
    404
    500
    501
    index
    installed
  )

  xargs -P4 -n1 -t "$0" html <<< "${pages[*]}"
}

httpd.conf() {
  xargs -t dhall text --file './httpd.conf.dhall' --output <<< './httpd.conf'
}

tarball() { tar -czvf www.tar.gz -- *.html *.js *.css *.conf; }

all() { html_all && httpd.conf && tarball; }

"$@"
