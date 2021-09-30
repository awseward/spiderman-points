let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

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
