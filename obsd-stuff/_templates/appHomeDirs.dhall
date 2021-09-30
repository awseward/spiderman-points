let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let List/map = Prelude.List.map

let lib = ../lib.dhall

let user = λ(cfg : lib.AppConfig) → cfg.slug

let homeContents =
      toMap
        { `deploy.sh` = ./deploy.sh as Text
        , `app-env.sh` =
            ''
            # Application configuration/secrets here as env vars, example:
            # SOME_TOKEN=abc123!@#
            ''
        }

let toEntry =
      λ(cfg : lib.AppConfig) → { mapKey = user cfg, mapValue = homeContents }

in  List/map
      lib.AppConfig
      { mapKey : Text, mapValue : List { mapKey : Text, mapValue : Text } }
      toEntry
