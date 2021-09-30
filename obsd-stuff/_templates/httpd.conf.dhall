let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

let renderServerBlock =
      λ(cfg : lib.AppConfig) →
        let domain = cfg.domain

        in  ''
            server "www.${domain}" {
              listen on * port 80
              root "/htdocs/www.${domain}"

              location "/.well-known/acme-challenge/*" {
                root "/acme"
                request strip 2
              }
            }
            ''

in  λ(cfgs : List lib.AppConfig) →
      Text/concatMapSep "\n\n" lib.AppConfig renderServerBlock cfgs
