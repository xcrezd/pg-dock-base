#!/bin/bash
set -e

chown -R postgres:postgres \
  /home/postgres \
  /var/lib/postgresql/data \
  /var/log/supervisor \
  /etc/scripts

if [ -f  /home/postgres/.ssh/id_rsa ]
then
	chmod 0600 /home/postgres/.ssh/id_rsa
fi

# remove files if exist from previous run
rm -f /var/run/postgresql/.s.PGSQL.5432 \
	/var/run/postgresql/.s.PGSQL.5432.lock \
	/var/lib/postgresql/data/postmaster.pid

if [ $# -eq 0 ]
  then
    echo "No arguments supplied - running pg-dock"
    . /etc/scripts/helpers/setup-wale.sh
    gosu postgres supervisord
  else
    exec "$@"
fi
