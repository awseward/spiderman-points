let imports = ./imports.dhall

let Map = imports.Map

let Service = ./Service.dhall

let Step = ./Step.dhall

in  { Type =
        { runs-on : List Text
        , container : Optional Text
        , services : Map.Type Text Service.Type
        , steps : List Step.Type
        }
    , default =
      { container = None Text
      , services = Map.empty Text Service.Type
      , steps = [] : List Step.Type
      }
    }
