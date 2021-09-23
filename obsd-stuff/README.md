This is just a place to sloppily dump stuff as I explore self-hosting this app
on an OpenBSD instance instead of Heroku.

In general, parts to consider are:

#### • Basic OS setup/housekeeping stuff

Create a non-root user to use
```sh
adduser # Then just follow the prompts
```

Add your ssh pubkey to new user's `~/.ssh/authorized_keys` so you can get back
in.

Add to `/etc/ssh/sshd_config`:
```
PermitRootLogin no
AuthenticationMethods publickey
PasswordAuthentication no
```

Probably quite a bit more here to mention…

#### • Setup for acme-client, LetsEncrypt stuff

See:
- `/etc/acme-client/acme-client.conf`
- `/etc/httpd.conf`
- `tls keypair …` directive in `/etc/relayd.conf`

#### • Setup for relayd

All of the stuff in `/etc/relayd.conf`, generally

#### • Set up for app daemon user

Create the daemon user
```sh
adduser -class daemon -batch spoints -shell ksh
```

Add the following to `/etc/doas.conf` so that the `deploy.sh` can restart the
`spointsd` daemon.

```
permit nopass spoints as root cmd rcctl args restart spointsd
```

#### • Set up for app runtime dependencies

```sh
pkg_add postgresql-client

# Probably a bit more…
```
