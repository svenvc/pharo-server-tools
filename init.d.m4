#! /bin/sh
### BEGIN INIT INFO
# Provides:          _SERVICE_NAME_ 
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: _DESCRIPTION_
### END INIT INFO

DESC="_DESCRIPTION_"
PHDIR=/home/_SERVICE_USER_/pharo/_SERVICE_NAME_
PHRUN=run-_SERVICE_NAME_
PHIMG=_IMAGE_NAME_

SU="su -l _SERVICE_USER_ -c"
PATH=/usr/sbin:/usr/bin:/sbin:/bin
SCRIPTNAME=$0

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

do_start()
{
        # Return
        #   0 if daemon has been started
        #   1 if daemon was already running
        #   2 if daemon could not be started
        $SU "$PHDIR/pharo-ctl.sh $PHRUN start $PHIMG"
        return 0
}

do_stop()
{
        # Return
        #   0 if daemon has been stopped
        #   1 if daemon was already stopped
        #   2 if daemon could not be stopped
        #   other if a failure occurred
        $SU "$PHDIR/pharo-ctl.sh $PHRUN stop $PHIMG"
        return 0
}

case "$1" in
  start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC"
        do_start
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC"
        do_stop
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  restart)
        log_daemon_msg "Restarting $DESC"
        do_stop
        case "$?" in
          0|1)
                do_start
                case "$?" in
                        0) log_end_msg 0 ;;
                        1) log_end_msg 1 ;; # Old process is still running
                        *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
          *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|restart}" >&2
        exit 3
        ;;
esac

:

