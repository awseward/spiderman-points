let imports = ./imports.dhall

let Map = imports.Map

let empty = Map.empty Text Text

in  { Type = Map.Type Text Text, default = empty, empty }
