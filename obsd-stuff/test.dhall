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
    , etc.`rc.d`.spointsd = ./_templates/spointsd as Text
    , usr.local.bin.spoints
      =
        ''
        #!/usr/bin/env bash

        set -euo pipefail

        . "${appDir}/app-env.sh" && cd "${appDir}" && "${appDir}/scripts/server.sh"
        ''
    }
