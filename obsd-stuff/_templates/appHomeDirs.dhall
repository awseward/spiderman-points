let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let List/map = Prelude.List.map

let Map = Prelude.Map

let lib = ../lib.dhall

let AppConfig = lib.AppConfig

let user = λ(cfg : AppConfig) → cfg.slug

let MapTextText = Map.Type Text Text

let MapEntry = Map.Entry Text MapTextText

let homeContents
    : AppConfig → MapTextText
    = λ(cfg : AppConfig) →
        toMap
          { `app_env.sh` =
              ''
              # Application configuration/secrets here as env vars, example:
              # SOME_TOKEN=abc123!@#
              ''
          , `deploy.sh` = ./deploy.sh as Text
          , `deploy_vars.sh` =
              ''
              owner='FIXME_owner'
              repo='FIXME_repo'
              app_name='${cfg.slug}'
              daemon_name='${cfg.slug}d''
          }

let keyValue
    : AppConfig → MapEntry
    = λ(cfg : AppConfig) →
        Map.keyValue MapTextText (user cfg) (homeContents cfg)

in  List/map AppConfig MapEntry keyValue
