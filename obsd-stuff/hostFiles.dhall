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
        , `rc.d` = ./_templates/daemons.dhall cfgs
        , `relayd.conf` = ./_templates/relayd.conf.dhall extIp cfgs
        }
      , home = ./_templates/appHomeDirs.dhall cfgs
      }
