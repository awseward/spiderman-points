let fn =
      λ(domain : Text) →
      λ(port : Natural) →
        ''
        # This is meant to be included in `/etc/httpd.conf`
        server "www.${domain}" {
          listen on 127.0.0.1 port ${Natural/show port}
          root "/htdocs/www.${domain}"
          alias "${domain}"
          log style forwarded

          location "/privacy" { request rewrite "/501.html" }
          location "/support" { request rewrite "/501.html" }
          location "/" { request rewrite "/index.html" }
          location "/installed" { request rewrite "/installed.html" }

          location not found "/*" { request rewrite "/404.html" }
        }
        ''

in  fn env:SPOINTS_DOMAIN as Text env:SPOINTS_INTERNAL_PORT
