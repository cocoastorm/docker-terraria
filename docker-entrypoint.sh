#!/bin/sh
user="terraria"
uid=${PUID-"1000"}
gid=${PGID-"1000"}

# set uid/gid before all else
if id terraria &> /dev/null ; then
  echo "entrypoint: changing terraria $uid:$gid"

  usermod -u $uid terraria
  groupmod -g $gid terraria
fi

config() {
  if [ ! -f "/config/serverconfig.txt" ]; then
    echo 'entrypoint: generating serverconfig.txt'

    # copy default server config if it exists
    if [ -f /opt/terraria/serverconfig-default.txt ]; then
      cp /opt/terraria/serverconfig-default.txt /config/serverconfig.txt
    else
      touch /config/serverconfig.txt
    fi

    # interject our own biased config options
    {
      echo ''
      echo 'worldpath=/worlds'
      echo 'port=7777'
    } >> /config/serverconfig.txt
  fi

  chown terraria:terraria -R /config
}

ownership() {
  id terraria &> /dev/null || return 1

  echo 'entrypoint: changing ownership of files to terraria'

  # internal to container filesystem
  chown -R terraria: /opt/terraria
  chown -R terraria: /opt/terraria/.local

  # volumes
  chown -R terraria: /config 
  chown -R terraria: /worlds
}

## init setup
config
ownership

set -e

# no arguments passed
# first arg is `-f` or `--some-option`
if [ "$#" -eq 0 -o "${1#-}" != "$1" ]; then
  set -- su-exec terraria tini -- mono --server --gc=sgen -O=all /opt/terraria/TerrariaServer.exe "$@"
else
  set -- su-exec terraria "$@"
fi

exec "$@"
