-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./test.dhall
let lib = ./lib.dhall

in  λ(extIp : Text) →
    λ(cfgs : List lib.AppConfig) →
      { etc =
        { `acme-client.conf` = ./_templates/acme-client.conf.dhall cfgs
        , `doas.conf` = ./_templates/doas.conf.dhall cfgs
        , `httpd.conf` = ./_templates/httpd.conf.dhall cfgs
        , `pf.conf` = ./_templates/pf.conf as Text
        , `rc.d_`
          -- TODO: Change this  from `rc.d_` `rc.d` when clear.
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
