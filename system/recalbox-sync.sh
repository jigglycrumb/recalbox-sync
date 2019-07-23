#!/bin/sh
#
# Sync recalbox to and from remote host
#
# Save as executable script /recalbox/share/system/custom.sh
# to have it run on boot and shutdown
# To run manually: /etc/init.d/S99custom {start|stop|restart|reload}

LOGFILE="/recalbox/share/system/logs/rsync.log"
LOCAL="/recalbox/share"
REMOTE="rsync://user@host/recalbox" # EDIT THIS
RSYNC_OPTS="-havP -zz --no-o --no-g --timeout=30 --append-verify --stats"
RETVAL=0

logheader() {
  touch $LOGFILE
  echo "" >>$LOGFILE
  echo "-----------------------------------------" >>$LOGFILE
  echo "" >>$LOGFILE
}

pull() {
  echo -n "Pulling latest bioses, roms, saves and screenshots: "

  logheader

  rsync $RSYNC_OPTS $REMOTE/bios $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $REMOTE/saves $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $REMOTE/screenshots $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS --delete $REMOTE/roms $LOCAL/ >>$LOGFILE

  RETVAL=$?
  echo "done"

  return $RETVAL
}

push() {
  echo -n "Pushing latest saves and screenshots"

  logheader

  rsync $RSYNC_OPTS $LOCAL/saves $REMOTE/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $LOCAL/screenshots $REMOTE/ >>$LOGFILE

  RETVAL=$?
  echo "done"

  return $RETVAL
}

sync() {
  push
  pull
}

cron() {
  sleep 3600
  logheader
  echo "cron run" >>$LOGFILE
  sync
  cron
}

case "$1" in
start)
  pull
  cron &
  ;;
stop)
  push
  ;;
restart)
  sync
  ;;
reload)
  sync
  ;;
push)
  push
  ;;
pull)
  pull
  ;;
*)
  echo "Usage: $0 {start|stop|restart|reload|push|pull}"
  exit 1
  ;;
esac

exit $?
