let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let Text/concatMapSep = Prelude.Text.concatMapSep

let acmeCmd = λ(handle : Text) → "acme-client -v '${handle}'"

in  λ(domains : List Text) →
      let acmeClientCmds = Text/concatMapSep " && " Text acmeCmd domains

      in  ''
          # renew SSL certs (see: https://www.openbsdhandbook.com/services/webserver/ssl)
          07 13 */3 * * acme-client ${acmeClientCmds} && rcctl reload httpd && relayctl reload
          ''
