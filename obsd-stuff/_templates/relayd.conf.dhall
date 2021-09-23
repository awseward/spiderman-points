λ(domain : Text) →
  ''
  ext_domain = "${domain}"
  ext_domain_www = "www.${domain}"

  log state changes
  log connection

  http protocol httpFilter {
    return error

    http headerlen 4096
    match request header set "X-Forwarded-For" value "$REMOTE_ADDR"
    match request header set "X-Forwarded-SPort" value "$REMOTE_PORT"
    match request header set "X-Forwarded-DPort" value "$SERVER_PORT"
    match response header remove "Server" value "*"
    match header log "Host"
    match header log "X-Forwarded-For"
    match header log "User-Agent"
    match header log "X-Req-Status"
    match url log
    match request tag "BAD_METHOD"
    match request method GET tag "OK_METH"
    match request method HEAD tag "OK_METH"
    block request quick tagged "BAD_METHOD"
    match request header "Host" value $ext_domain tag "OK_REQ"
    match request header "Host" value $ext_domain_www tag "OK_REQ"
    block request quick tagged "OK_METH" tag "BAD_HH"
    block request quick path "*.php" tag NO_PHP
    block request quick path "*.cgi" tag NO_CGI
    block request quick path "*.js" tag NO_JS
    block request quick path "*.asp" tag NO_ASP
    block tag "BAD_REQ"
    pass request tagged "OK_REQ"
  }

  http protocol httpsFilter {
    return error
    http headerlen 4096
    tls ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256"
    tls edh
    tls keypair $ext_domain
    match request header set "X-Forwarded-For" value "$REMOTE_ADDR"
    match request header set "X-Forwarded-SPort" value "$REMOTE_PORT"
    match request header set "X-Forwarded-DPort" value "$SERVER_PORT"
    match response header remove "Server" value "*"
    match header log "Host"
    match header log "X-Forwarded-For"
    match header log "User-Agent"
    match header log "X-Req-Status"
    match url log
    match response header set "Strict-Transport-Security" value "max-age=63072000; includeSubdomains; preload"
    match request tag "BAD_METHOD"
    match request method GET tag "OK_METH"
    match request method HEAD tag "OK_METH"
    block request quick tagged "BAD_METHOD"
    match request header "Host" value $ext_domain tag "OK_REQ"
    match request header "Host" value $ext_domain_www tag "OK_REQ"
    block request quick tagged "OK_METH" tag "BAD_HH"
    block request quick path "*.php" tag NO_PHP
    block request quick path "*.cgi" tag NO_CGI
    # block request quick path "*.js" tag NO_JS
    block request quick path "*.asp" tag NO_ASP
    block tag "BAD_REQ"
    pass request tagged "OK_REQ"
  }

  relay www {
    listen on $ext_domain port 80
    protocol httpFilter
    forward to "127.0.0.1" port 4567
  }

  relay wwwssl {
    listen on $ext_domain port 443 tls
    protocol httpsFilter
    forward to "127.0.0.1" port 4567
  }
  ''
