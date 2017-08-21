#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "" ]; then
    set -- --ansi -n -vv
fi
/satis-server/bin/notify.sh "Starting full repository rebuild" "gray"
satis build "$@" /etc/satis/satis.json /etc/satis/output 2>&1
EXIT_CODE="$?"
scw_log "Exit code: $EXIT_CODE"
if [ "$EXIT_CODE" == "0" ]; then
    scw_set_global_ts
    if [ "$NOTIFY_DEBUG" == "1" ]; then
        PACKAGE_LIST=`/satis-server/bin/satis-list.sh -s | jq -sR '.' | cut -d '"' -f2`
        /satis-server/bin/notify.sh "Successfully rebuilt all packages <pre>$PACKAGE_LIST</pre>" "green"
    else
        /satis-server/bin/notify.sh "Successfully rebuilt all packages" "green"
    fi
    exit 0
fi
/satis-server/bin/notify.sh "Failed to rebuild all packages" "red"