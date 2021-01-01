let Env = ./Env.dhall

let With = ./With.dhall

in  { Type =
        { id : Optional Text
        , `if` : Optional Text
        , name : Optional Text
        , uses : Optional Text
        , run : Optional Text
        , `with` : With.Type
        , env : Env.Type
        , continue-on-error : Optional Bool
        , timeout-minutes : Optional Natural
        }
    , default =
      { id = None Text
      , `if` = None Text
      , name = None Text
      , uses = None Text
      , run = None Text
      , `with` = With.empty
      , env = Env.empty
      , continue-on-error = None Bool
      , timeout-minutes = None Natural
      }
    }
