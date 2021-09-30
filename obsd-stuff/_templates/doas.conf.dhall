let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

let renderLine =
      λ(cfg : lib.AppConfig) →
        let daemonName -- probably want to use this from `lib` instead
                       =
              "${cfg.slug}d"

        in  "permit nopass ${cfg.slug} as root cmd rcctl args restart ${daemonName}"

in  Text/concatMapSep "\n" lib.AppConfig renderLine
