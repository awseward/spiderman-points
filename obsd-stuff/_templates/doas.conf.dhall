let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let Text/concatMapSep = Prelude.Text.concatMapSep

let lib = ../lib.dhall

let renderLine =
      λ(cfg : lib.AppConfig) →
        let daemonName -- probably want to use this from `lib` instead
                       =
              "${cfg.slug}d"

        in  "permit nopass ${cfg.slug} as root cmd rcctl args restart ${daemonName}"

in  Text/concatMapSep "\n" lib.AppConfig renderLine
