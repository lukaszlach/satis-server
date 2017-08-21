#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "" ]; then
    scw_log_error "Repository URL was not passed as first parameter"
    exit 0
fi
REPOSITORY_URL="$1"
shift
if [ "$1" == "" ]; then
    set -- --ansi -n -vv
fi
satis add "$@" "$REPOSITORY_URL" /etc/satis/satis.json 2>&1
scw_log "Exit code: $?"