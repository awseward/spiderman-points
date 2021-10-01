let lib = ../lib.dhall

let Prelude = lib.Prelude

let Text/concatMapSep = Prelude.Text.concatMapSep

let renderLines =
      λ(cfg : lib.AppConfig) →
        let daemonName -- probably want to use this from `lib` instead
                       =
              "${cfg.slug}d"

        in  ''
            permit nopass ${cfg.slug} as root cmd rcctl args check   ${daemonName}
            permit nopass ${cfg.slug} as root cmd rcctl args reload  ${daemonName}
            permit nopass ${cfg.slug} as root cmd rcctl args restart ${daemonName}
            permit nopass ${cfg.slug} as root cmd rcctl args start   ${daemonName}
            permit nopass ${cfg.slug} as root cmd rcctl args stop    ${daemonName}
            ''

in  λ(cfgs : List lib.AppConfig) →
      Text/concatMapSep "\n" lib.AppConfig renderLines cfgs ++ "\n"
