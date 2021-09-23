λ(domain : Text) →
  ''
  # Probably all you need is the `/.well-known/acme-challenge/*` bit, plus maybe
  # a little more, if all you need is relayd to reverse-proxy and SSL terminate
  # for a web app, as opposed to serving static files.

  server "www.${domain}" {
    listen on * tls port 443
    root "/htdocs/${domain}"
    tls {
      certificate "/etc/ssl/${domain}.fullchain.pem"
      key "/etc/ssl/private/${domain}.key"
    }
    location "/.well-known/acme-challenge/*" {
      root "/acme"
      request strip 2
    }
  }

  server "${domain}" {
    listen on * tls port 443
    tls {
      certificate "/etc/ssl/${domain}.fullchain.pem"
      key "/etc/ssl/private/${domain}.key"
    }
    block return 301 "https://www.${domain}$REQUEST_URI"
  }

  server "www.${domain}" {
    listen on * port 80
    alias "${domain}"
    block return 301 "https://www.${domain}$REQUEST_URI"
  }
  ''
