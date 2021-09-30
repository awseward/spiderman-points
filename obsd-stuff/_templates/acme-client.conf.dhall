let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

let renderDomainBlock =
      λ(cfg : lib.AppConfig) →
        let domain = cfg.domain

        in  ''
            domain ${domain} {
              alternative names { www.${domain} }
              domain key "/etc/ssl/private/${domain}.key"
              domain full chain certificate "/etc/ssl/${domain}.crt"
              sign with letsencrypt
            }''

in  λ(cfgs : List lib.AppConfig) →
      let domainBlocks =
            Text/concatMapSep "\n\n" lib.AppConfig renderDomainBlock cfgs

      in  ''
          # https://www.openbsdhandbook.com/services/webserver/ssl/

          authority letsencrypt {
            api url "https://acme-v02.api.letsencrypt.org/directory"
            account key "/etc/acme/letsencrypt-privkey.pem"
          }

          ${domainBlocks}
          ''
