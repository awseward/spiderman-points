let lib = ../lib.dhall

let indent = lib.indent

let fwdHeaders =
      indent
        ''
        match request header set "X-Forwarded-For" value "$REMOTE_ADDR"
        match request header set "X-Forwarded-SPort" value "$REMOTE_PORT"
        match request header set "X-Forwarded-DPort" value "$SERVER_PORT"''

let serverRespHeader =
      "  match response header set \"Server\" value \"EE EEEE E EEEEEE E EEE EEEE EEEEE EE EEEE EEE (these are dolphin sounds)\""

let log =
      indent
        ''
        match header log "Host"
        match header log "X-Forwarded-For"
        match header log "User-Agent"
        match header log "X-Req-Status"
        match url log''

let sts =
      "  match response header set \"Strict-Transport-Security\" value \"max-age=63072000; includeSubdomains; preload\""

let reqMethods =
      indent
        ''
        match request tag "BAD_METHOD"
        match request method GET tag "OK_METH"
        match request method HEAD tag "OK_METH"
        match request method POST tag "OK_METH"
        block request quick tagged "BAD_METHOD"''

let fileTypes =
      indent
        ''
        block request quick path "*.php" tag NO_PHP
        block request quick path "*.cgi" tag NO_CGI
        # block request quick path "*.js" tag NO_JS
        block request quick path "*.asp" tag NO_ASP''

let finish =
      indent
        ''
        block tag "BAD_REQ"
        pass request tagged "OK_REQ"''

in  λ(extIp : Text) →
    λ(appConfigs : List lib.AppConfig) →
      ''
      ${lib.renderDomainMacros appConfigs}

      ${lib.renderTables appConfigs}

      log state changes
      log connection

      http protocol httpFilter {
        # return error

        http headerlen 4096

      ${lib.renderProtoFwds appConfigs}

      ${fwdHeaders}

      ${serverRespHeader}
        match response header set "Cache-Control" value "max-age=1814400; public"

      ${log}

      ${sts}

      ${reqMethods}
      ${lib.renderAllowHosts appConfigs}
        block request quick tagged "OK_METH" tag "BAD_HH"

      ${fileTypes}

      ${finish}
      }


      http protocol httpsFilter {
        # return error

        http headerlen 4096

      ${lib.renderProtoFwds appConfigs}

      ${lib.renderTlsKeypairs appConfigs}

      ${fwdHeaders}

      ${serverRespHeader}
        match response header set "Cache-Control" value "max-age=1814400; public"

      ${log}

      ${sts}

      ${reqMethods}
      ${lib.renderAllowHosts appConfigs}
        block request quick tagged "OK_METH" tag "BAD_HH"

      ${fileTypes}

      ${finish}
      }


      relay www {
        listen on ${extIp} port 80
        protocol httpFilter

      ${lib.renderFwds appConfigs}
      }


      relay wwwssl {
        listen on ${extIp} port 443 tls
        protocol httpsFilter

      ${lib.renderFwds appConfigs}
      }
      ''
