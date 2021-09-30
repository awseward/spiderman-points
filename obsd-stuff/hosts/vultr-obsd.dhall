-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./hosts/vultr-obsd.dhall
let lib = ../lib.dhall

let hostFiles = ../hostFiles.dhall

let hostCfg =
      { ip = "66.42.11.73"
      , appCfgs =
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
              , repoOwner = "awseward"
              , repoName = "b2-backend-thing"
              , slug = "drewrel"
              }
            ]
          : List lib.AppConfig
      }

let base = hostFiles hostCfg.ip hostCfg.appCfgs

let extraCruft -- FIXME: Fit this into everything better
               =
      { etc.`rc.d`.spointsd = ../_templates/spointsd as Text
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

let merged =
    -- Wow, this sorta sucks that you can't just merge deep recursively… What I
    -- mean is that if you just do `base ⫽ extraCruft`, it clobbers any
    -- collisions' deeper nested fields from the left-hand side

      base ⫽ { etc = base.etc ⫽ extraCruft.etc }

in  merged
