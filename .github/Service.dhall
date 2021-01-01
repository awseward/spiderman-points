let Env = ./Env.dhall

in  { Type = { env : Env.Type, image : Optional Text, options : Optional Text }
    , default.env = Env.empty
    }
