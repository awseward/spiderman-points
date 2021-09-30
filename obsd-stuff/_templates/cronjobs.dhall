let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

let acmeCmd = λ(handle : Text) → "acme-client -v '${handle}'"

in  λ(domains : List Text) →
      let acmeClientCmds = Text/concatMapSep " && " Text acmeCmd domains

      in  ''
          # renew SSL certs (see: https://www.openbsdhandbook.com/services/webserver/ssl)
          07 13 */3 * * acme-client ${acmeClientCmds} && rcctl reload httpd && relayctl reload
          ''
