let lib = ../lib.dhall

let Prelude = lib.Prelude

let List/map = Prelude.List.map

let Map = Prelude.Map

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
          , `app_start.sh` = ./app_start.sh as Text
          , `deploy.sh` = ./deploy.sh as Text
          , `deploy_vars.sh` =
              ''
              owner='${cfg.repoOwner}'
              repo='${cfg.repoName}'
              app_name='${cfg.slug}'
              daemon_name='${cfg.slug}d''
          }

let keyValue
    : AppConfig → MapEntry
    = λ(cfg : AppConfig) →
        Map.keyValue MapTextText (user cfg) (homeContents cfg)

in  List/map AppConfig MapEntry keyValue
