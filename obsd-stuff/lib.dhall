let Prelude =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.0.0/Prelude/package.dhall
        sha256:46c48bba5eee7807a872bbf6c3cb6ee6c2ec9498de3543c5dcc7dd950e43999d

let Text/concatSep = Prelude.Text.concatSep

let Text/concatMapSep = Prelude.Text.concatMapSep

let Text/spaces = Prelude.Text.spaces

let AppConfig =
      { domain : Text
      , onDeploy : Text
      , pexp : Text
      , relayAddrs : List Text
      , relayPort : Natural
      , repoOwner : Text
      , repoName : Text
      , slug : Text
      }

let indent =
      λ(text : Text) →
        let spaces = Text/spaces 2

        let text_ =
              Text/replace
                "\n"
                ''

                ${spaces}''
                text

        in  "${spaces}${text_}"

let lined = Text/concatMapSep "\n"

let tableName = λ(cfg : AppConfig) → "<${cfg.slug}>"

let domainMacro = λ(cfg : AppConfig) → "${cfg.slug}_domain"

let domainMacroWww = λ(cfg : AppConfig) → "${domainMacro cfg}_www"

let renderAllowHost =
      λ(cfg : AppConfig) →
            "  match request header \"Host\" value \$${domainMacro
                                                         cfg} tag \"OK_REQ\""
        ++  "\n"
        ++  "  match request header \"Host\" value \$${domainMacroWww
                                                         cfg} tag \"OK_REQ\""

let renderAllowHosts = lined AppConfig renderAllowHost

let renderDomainMacro =
      λ(cfg : AppConfig) →
        ''
        ${cfg.slug}_domain = "${cfg.domain}"
        ${cfg.slug}_domain_www = "www.${cfg.domain}"''

let renderDomainMacros = Text/concatMapSep "\n\n" AppConfig renderDomainMacro

let renderFwd =
      λ(cfg : AppConfig) →
        "  forward to ${tableName cfg} port ${Natural/show cfg.relayPort}"

let renderFwds = lined AppConfig renderFwd

let renderProtoFwd =
      λ(cfg : AppConfig) →
        "  match request header \"Host\" value \"*${cfg.domain}\" forward to ${tableName
                                                                                 cfg}"

let renderProtoFwds = lined AppConfig renderProtoFwd

let renderTable =
      λ(cfg : AppConfig) →
        let spaced = Text/concatSep " "

        in  "table ${tableName cfg} { ${spaced cfg.relayAddrs} }"

let renderTables = lined AppConfig renderTable

let renderTlsKeypair = λ(cfg : AppConfig) → "  tls keypair \$${domainMacro cfg}"

let renderTlsKeypairs = lined AppConfig renderTlsKeypair

in  { AppConfig
    , Prelude
    , indent
    , renderAllowHost
    , renderAllowHosts
    , renderDomainMacro
    , renderDomainMacros
    , renderFwd
    , renderFwds
    , renderProtoFwd
    , renderProtoFwds
    , renderTable
    , renderTables
    , renderTlsKeypair
    , renderTlsKeypairs
    }
