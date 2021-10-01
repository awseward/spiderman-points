let lib = ../lib.dhall

let Prelude = lib.Prelude

let List/map = Prelude.List.map

let daemon = λ(cfg : lib.AppConfig) → "${cfg.slug}d"

let daemonScript =
      λ(cfg : lib.AppConfig) →
        ''
            #!/bin/sh
            #
            # http://cvsweb.openbsd.org/cgi-bin/cvsweb/ports/infrastructure/templates/rc.template
            #
            # See also: https://gist.github.com/anon987654321/4532cf8d6c59c1f43ec8973faa031103

            rc_bg=YES
            rc_reload=NO

            daemon_user='${cfg.slug}'
            daemon='/home/${cfg.slug}/app_start.sh'
            daemon_flags='"/home/${cfg.slug}/${cfg.slug}" "/home/${cfg.slug}/app_env.sh"'
            daemon_logger='daemon.info'

            . /etc/rc.d/rc.subr

            pexp='${cfg.pexp} '

            rc_check() {
              pgrep -T "\$\{daemon_rtable\}" -q -f "\$\{pexp\}"
            }

            rc_stop() {
              pkill -T "\$\{daemon_rtable\}" -f "\$\{pexp\}"
            }

            rc_cmd $1
        ''

let toEntry =
      λ(cfg : lib.AppConfig) →
        { mapKey = daemon cfg, mapValue = daemonScript cfg }

in  List/map lib.AppConfig { mapKey : Text, mapValue : Text } toEntry
