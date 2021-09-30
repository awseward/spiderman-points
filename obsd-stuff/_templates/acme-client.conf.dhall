let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let Text/concatMapSep = Prelude.Text.concatMapSep

let lib = ../lib.dhall

let renderDomainBlock =
      λ(appConfig : lib.AppConfig) →
        let domain = appConfig.domain

        in  ''
            domain ${domain} {
              alternative names { www.${domain} }
              domain key "/etc/ssl/private/${domain}.key"
              domain full chain certificate "/etc/ssl/${domain}.crt"
              sign with letsencrypt
            }''

in  λ(appConfigs : List lib.AppConfig) →
      let domainBlocks =
            Text/concatMapSep "\n\n" lib.AppConfig renderDomainBlock appConfigs

      in  ''
          # https://www.openbsdhandbook.com/services/webserver/ssl/

          authority letsencrypt {
            api url "https://acme-v02.api.letsencrypt.org/directory"
            account key "/etc/acme/letsencrypt-privkey.pem"
          }

          ${domainBlocks}
          ''
