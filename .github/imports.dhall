let dhall-misc =
      https://raw.githubusercontent.com/awseward/dhall-misc/20210120092814/package.dhall sha256:b32145fee2ff889e178d8000c117702c6ebdf1ab66a712ff1e3a3719f83eb85f

let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v20.0.0/Prelude/package.dhall sha256:21754b84b493b98682e73f64d9d57b18e1ca36a118b81b33d0a243de8455814b

in  { Prelude, dhall-misc } ⫽ Prelude.{ Map, Text }
