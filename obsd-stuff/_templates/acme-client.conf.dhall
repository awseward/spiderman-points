λ(domain : Text) →
  ''
  # https://www.openbsdhandbook.com/services/webserver/ssl/

  authority letsencrypt {
    api url "https://acme-v02.api.letsencrypt.org/directory"
    account key "/etc/acme/letsencrypt-privkey.pem"
  }

  domain ${domain} {
    alternative names { www.${domain} }
    domain key "/etc/ssl/private/${domain}.key"
    domain full chain certificate "/etc/ssl/${domain}.crt"
    sign with letsencrypt
  }
  ''
