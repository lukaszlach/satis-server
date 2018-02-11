#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "" ]; then
    scw_log_error "Repository URL was not passed as first parameter"
    exit 1
fi
REPOSITORY_URL="$1"
shift
scw_satis_verify_repository_exists "$REPOSITORY_URL"
PACKAGE_NAME=`scw_get_repository_name "$REPOSITORY_URL"`
if [ "$1" == "" ]; then
    set -- --ansi -n -vv
fi
/satis-server/bin/notify.sh "Starting to build <b>$PACKAGE_NAME</b>" "gray"
scw_wait satis build --repository-url="$REPOSITORY_URL" "$@" /etc/satis/satis.json /etc/satis/output 2>&1
EXIT_CODE="$?"
scw_log "Exit code: $EXIT_CODE"
if [ "$EXIT_CODE" == "0" ]; then
    scw_set_ts "$REPOSITORY_URL"
    if [ "$NOTIFY_DEBUG" == "1" ]; then
        PACKAGE_DETAILS_MESSAGE=`/satis-server/bin/satis-show.sh "$REPOSITORY_URL" | jq -sR '.' | cut -d '"' -f2`
        /satis-server/bin/notify.sh "Successfully built <b>$PACKAGE_NAME</b> <pre>$PACKAGE_DETAILS_MESSAGE</pre>" "green"
    else
        /satis-server/bin/notify.sh "Successfully built <b>$PACKAGE_NAME</b>" "green"
    fi
    exit 0
fi
/satis-server/bin/notify.sh "Failed to build <b>$PACKAGE_NAME</b>" "red"