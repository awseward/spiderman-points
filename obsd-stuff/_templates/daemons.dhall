let lib = ../lib.dhall

let Prelude = lib.Prelude

let List/map = Prelude.List.map

let daemon = λ(cfg : lib.AppConfig) → "${cfg.slug}d"

let toEntry =
      λ(cfg : lib.AppConfig) →
        { mapKey = daemon cfg, mapValue = ./rc.template as Text }

in  List/map lib.AppConfig { mapKey : Text, mapValue : Text } toEntry
