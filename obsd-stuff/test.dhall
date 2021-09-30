-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./test.dhall
let lib = ./lib.dhall

let extIp = "66.42.11.73"

let cfgs =
      [ { domain = "spoints.co.uk"
        , relayAddrs = [ "127.0.0.1" ]
        , relayPort = 4567
        , repoOwner = "awseward"
        , repoName = "spiderman-points"
        , slug = "spoints"
        }
      , { domain = "drewrelic.com"
        , relayAddrs = [ "127.0.0.1" ]
        , relayPort = 80
        , repoOwner = "FIXME"
        , repoName = "FIXME"
        , slug = "drewrel"
        }
      ]

in  { etc =
      { `acme-client.conf` = ./_templates/acme-client.conf.dhall cfgs
      , `doas.conf` = ./_templates/doas.conf.dhall cfgs
      , `httpd.conf` = ./_templates/httpd.conf.dhall cfgs
      , `pf.conf` = ./_templates/pf.conf as Text
      , `rc.d`.spointsd = ./_templates/spointsd as Text
      , `rc.d_`
        -- TODO: Replace `rc.d.spointsd` above with this if it seems viable
        = ./_templates/daemons.dhall cfgs
      , `relayd.conf` = ./_templates/relayd.conf.dhall extIp cfgs
      }
    , home = ./_templates/appHomeDirs.dhall cfgs
    , usr.local.bin.spoints
      =
        let slug = "spoints"

        let appDir = "/home/${slug}/${slug}"

        in  ''
            #!/usr/bin/env bash

            set -euo pipefail

            . "${appDir}/app_env.sh" && cd "${appDir}" && "${appDir}/scripts/server.sh"
            ''
    }
