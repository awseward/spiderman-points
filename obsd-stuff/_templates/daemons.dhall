let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let List/map = Prelude.List.map

let lib = ../lib.dhall

let daemon = λ(cfg : lib.AppConfig) → "${cfg.slug}d"

let toEntry =
      λ(cfg : lib.AppConfig) →
        { mapKey = daemon cfg, mapValue = ./rc.template as Text }

in  List/map lib.AppConfig { mapKey : Text, mapValue : Text } toEntry
