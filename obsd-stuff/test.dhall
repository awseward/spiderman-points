-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./test.dhall
let lib = ./lib.dhall

let extIp = "66.42.11.73"

let appConfigs =
      [ { slug = "spoints"
        , domain = "spoints.co.uk"
        , relayAddrs = [ "127.0.0.1" ]
        , relayPort = 4567
        }
      , { slug = "drewrelic"
        , domain = "drewrelic.com"
        , relayAddrs = [ "127.0.0.1" ]
        , relayPort = 80
        }
      ]

let appName_ = "spoints"

let appDir = "/home/${appName_}/${appName_}"

let domain = "spoints.co.uk"

in  { etc =
      { `acme-client.conf` = ./_templates/acme-client.conf.dhall domain
      , `doas.conf` = ./_templates/doas.conf.dhall appName_
      , `httpd.conf` = ./_templates/httpd.conf.dhall domain
      , `pf.conf` = ./_templates/pf.conf as Text
      , `rc.d`.spointsd = ./_templates/spointsd as Text
      , `relayd.conf` = ./_templates/relayd.conf.dhall extIp appConfigs
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
