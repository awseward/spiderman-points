let imports = ../imports.dhall

let GHA = imports.GHA

let Job = GHA.Job

let On =
      let base = GHA.On

      let _mkPushPull =
            λ(name : Text) →
            λ(cfg : base.PushPull.Type) →
              { mapKey = name
              , mapValue = base.pushPull (base.PushPull.fix cfg)
              }

      in    base
          ⫽ { include = λ(xs : List Text) → Some (base.PushPull.include xs)
            , ignore = λ(xs : List Text) → Some (base.PushPull.ignore xs)
            , _mkPushPull
            , push = _mkPushPull "push"
            , pullRequest = _mkPushPull "pull_request"
            }

let Service = GHA.Service

let Step = GHA.Step

let Workflow = GHA.Workflow

let fmtOptions = imports.Text.concatSep " "

in  Workflow::{
    , name = "CI"
    , on =
        On.map
          [ On.pullRequest
              On.PushPull::{ branches = On.include [ "master", "main" ] }
          ]
    , jobs = toMap
        { schema = Job::{
          , runs-on = [ "ubuntu-latest" ]
          , container = Some "ruby:3.0.0"
          , services = toMap
              { postgres = Service::{
                , image = Some "postgres:12.4"
                , env = toMap { POSTGRES_PASSWORD = "postgres" }
                , options = Some
                    ( fmtOptions
                        [ "--health-cmd pg_isready"
                        , "--health-interval 10s"
                        , "--health-timeout 5s"
                        , "--health-retries 5"
                        ]
                    )
                }
              }
          , steps =
            [ Step.mkUses
                Step.Common::{=}
                Step.Uses::{ uses = "actions/checkout@v2" }
            , Step.mkRun
                Step.Common::{
                , name = Some "Check schema.rb"
                , env = toMap
                    { POSTGRES_HOST = "postgres"
                    , POSTGRES_PORT = "5432"
                    , POSTGRES_USER = "postgres"
                    , POSTGRES_PASSWORD = "postgres"
                    , RACK_ENV = "ci"
                    }
                }
                ''
                bundle install \
                  && bundle exec rake db:create \
                  && bundle exec rake db:migrate \
                  && git diff --color --exit-code
                ''
            ]
          }
        }
    }
