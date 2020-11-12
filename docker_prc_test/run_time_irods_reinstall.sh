#!/bin/sh
DELAY=0
[ -n "$1" ] && DELAY="$1"
service postgresql start
IRODSCTL=/var/lib/irods/irodsctl 
if [ -x $IRODSCTL ]; then 
  : # don't interrupt docker build
else 
  su - irods -c "$IRODSCTL stop"
fi
sleep $DELAY
su - postgres -c 'dropdb ICAT ; createdb ICAT'
sleep $DELAY
python /var/lib/irods/scripts/setup_irods.py </var/lib/irods/packaging/localhost_setup_postgres.input
