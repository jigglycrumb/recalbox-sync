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

pull_remote() {
  echo -n "Pulling latest roms and saves: "

  logheader

  rsync $RSYNC_OPTS $REMOTE/bios $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $REMOTE/saves $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $REMOTE/screenshots $LOCAL/ >>$LOGFILE &&
    rsync $RSYNC_OPTS --delete $REMOTE/roms $LOCAL/ >>$LOGFILE

  RETVAL=$?
  echo "done"

  return $RETVAL
}

push_remote() {
  echo -n "Pushing latest roms and saves: "

  logheader

  rsync $RSYNC_OPTS $LOCAL/bios $REMOTE/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $LOCAL/saves $REMOTE/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $LOCAL/screenshots $REMOTE/ >>$LOGFILE &&
    rsync $RSYNC_OPTS $LOCAL/roms $REMOTE/ >>$LOGFILE

  RETVAL=$?
  echo "done"

  return $RETVAL
}

sync() {
  push_remote
  pull_remote
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
  pull_remote
  cron &
  ;;
stop)
  push_remote
  ;;
restart)
  sync
  ;;
reload)
  sync
  ;;
*)
  echo "Usage: $0 {start|stop|restart|reload}"
  exit 1
  ;;
esac

exit $?
