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
adduser -class daemon -shell ksh -batch spoints
```

Add the following to `/etc/doas.conf` so that the `deploy.sh` can restart the
`spointsd` daemon.

```
permit nopass spoints as root cmd rcctl args restart spointsd
```

#### • Set up for app runtime dependencies

```sh
pkg_add postgresql-client postgresql-server ruby-3.0.2 node

# Probably a bit more…
```

# Rough rundown of "phases"

### 1. New machine

Set up things like:

- non-root admin user
- sshd_config
- doas.conf
- pf?
- … etc.

### 2. Setup deployment tools

- Essentially, land `deploy.sh`
- Possibly have this all run as a "deployer" user or something?

### 3a. Per-app first deployment

- Add app user
- Do acme-client/httpd/relayd stuff
- Add doas rules
- Set up app daemon
- Set up other runtime dependencies (postgres, ruby, etc.)

- Land the app code
- Start the daemon

### 3. Per-app deployment

- Land the new app code
- Restart the daemon
