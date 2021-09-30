let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let Text/concatMapSep = Prelude.Text.concatMapSep

let lib = ../lib.dhall

let renderServerBlock =
      λ(appConfig : lib.AppConfig) →
        let domain = appConfig.domain

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

in  λ(appConfigs : List lib.AppConfig) →
      Text/concatMapSep "\n\n" lib.AppConfig renderServerBlock appConfigs
