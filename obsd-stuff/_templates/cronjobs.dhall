λ(domain : Text) →
  ''
  # renew SSL certs (see: https://www.openbsdhandbook.com/services/webserver/ssl)
  07 13 */3 * * acme-client ${domain} && rcctl reload httpd # Maybe also want to re{load/start} relayd, (?… <app>d …?)
  ''
