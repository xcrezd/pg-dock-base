#!/bin/bash
set -e

chown -R postgres:postgres \
  /home/postgres \
  /var/lib/postgresql/data \
  /var/log/supervisor \
  /etc/scripts

if [ $# -eq 0 ]
  then
    echo "No arguments supplied - running pg-dock"
    gosu postgres supervisord
  else
    exec "$@"
fi