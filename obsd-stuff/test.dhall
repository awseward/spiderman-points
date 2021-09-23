-- Usage:
--
-- dhall to-directory-tree --output . <<< ./test.dhall
let domain = "spoints.co.uk"

in  { etc =
      { `acme-client.conf` = ./_templates/acme-client.conf.dhall domain
      , `httpd.conf` = ./_templates/httpd.conf.dhall domain
      , `rc.d`.spointsd = ./_templates/rc.d/spointsd.dhall
      , `relayd.conf` = ./_templates/relayd.conf.dhall domain
      }
    }
