λ(domain : Text) →
  ''
  server "www.${domain}" {
    listen on * port 80
    location "/.well-known/acme-challenge/*" {
      root "/acme"
      request strip 2
    }
  }
  ''
