-- Usage:
--
-- dhall to-directory-tree --output _ <<< ./hosts/vultr-obsd.dhall
let lib = ../lib.dhall

let hostFiles = ../hostFiles.dhall

let hostCfg =
      { ip = "66.42.11.73"
      , appCfgs =
            [ { domain = "spoints.co.uk"
              , pexp = "ruby.*puma.*spoints"
              , relayAddrs = [ "127.0.0.1" ]
              , relayPort = 4567
              , repoOwner = "awseward"
              , repoName = "spiderman-points"
              , slug = "spoints"
              }
            , { domain = "drewrelic.com"
              , pexp
                -- this is probably just completely wrong
                = "npm start"
              , relayAddrs = [ "127.0.0.1" ]
              , relayPort = 5001
              , repoOwner = "awseward"
              , repoName = "b2-backend-thing"
              , slug = "drewrel"
              }
            ]
          : List lib.AppConfig
      }

in  hostFiles hostCfg.ip hostCfg.appCfgs
