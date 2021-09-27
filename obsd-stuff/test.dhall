-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./test.dhall
let appName = "spoints"

let appDir = "/home/${appName}/${appName}"

let domain = "spoints.co.uk"

in  { etc =
      { `acme-client.conf` = ./_templates/acme-client.conf.dhall domain
      , `doas.conf` = ./_templates/doas.conf.dhall appName
      , `httpd.conf` = ./_templates/httpd.conf.dhall domain
      , `pf.conf` = ./_templates/pf.conf as Text
      , `rc.d`.spointsd = ./_templates/spointsd as Text
      , `relayd.conf` = ./_templates/relayd.conf.dhall domain
      }
    , home.spoints
      =
      { `deploy.sh` = ./_templates/deploy.sh as Text
      , `app-env.sh` =
          ''
          # Application configuration/secrets here as env vars, example:
          # SOME_TOKEN=abc123!@#
          ''
      }
    , usr.local.bin.spoints
      =
        ''
        #!/usr/bin/env bash

        set -euo pipefail

        . "${appDir}/app-env.sh" && cd "${appDir}" && "${appDir}/scripts/server.sh"
        ''
    }
