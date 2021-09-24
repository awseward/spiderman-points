-- Usage:
--
-- dhall to-directory-tree --output . <<< ./test.dhall
let appName = "spoints"

let appDir = "/home/${appName}/${appName}"

let domain = "spoints.co.uk"

in  { etc =
      { `acme-client.conf` = ./_templates/acme-client.conf.dhall domain
      , `doas.conf` = ./_templates/doas.conf.dhall appName
      , `httpd.conf` = ./_templates/httpd.conf.dhall domain
      , `relayd.conf` = ./_templates/relayd.conf.dhall domain
      }
    , usr.local.bin.spoints
      =
        ''
        #!/usr/bin/env bash

        set -euo pipefail

        cd "${appDir}" && RACK_env=production "${appDir}/scripts/server.sh"
        ''
    }
