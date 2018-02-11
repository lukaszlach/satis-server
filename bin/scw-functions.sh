#!/usr/bin/env sh
CL_RED='\033[0;31m'
CL_YELLOW='\033[0;93m'
CL_DEFAULT='\033[0m'
SCW_DIR="/var/satis-server"
mkdir -p "$SCW_DIR" "$SCW_DIR/last_updated"

scw_log () {
    echo -e "$@"
}
scw_log_error () {
    echo -e "$CL_RED[ERROR]$CL_DEFAULT $@"
}
scw_log_warning () {
    echo -e "$CL_YELLOW[WARNING]$CL_DEFAULT $@"
}
scw_header () {
    scw_log "satis-server $SATIS_SERVER_VERSION"
}
scw_get_ts_filename () {
    echo "$SCW_DIR/last_updated/`echo "$1" | md5sum | cut -c1-32`.ts"
}
scw_set_ts() {
    FILENAME=`scw_get_ts_filename "$1"`
    date +"%s" > "$FILENAME"
}
scw_get_ts() {
    FILENAME=`scw_get_ts_filename "$1"`
    if [ -f "$FILENAME" ]; then
        cat "$FILENAME"
    fi
}
scw_get_visible_ts() {
    TS_VALUE=`scw_get_ts "$1"`
    GLOBAL_TS_VALUE=`scw_get_global_ts`
    if [ "$TS_VALUE" == "" ] && [ "$GLOBAL_TS_VALUE" == "" ]; then
        echo "never"
    else
        TS_VALUE=${TS_VALUE:-0}
        GLOBAL_TS_VALUE=${GLOBAL_TS_VALUE:-0}
        test "$TS_VALUE" -lt "$GLOBAL_TS_VALUE" && TS_VALUE="$GLOBAL_TS_VALUE"
        date -d "@$TS_VALUE" +%c
    fi
}
scw_set_global_ts() {
    scw_set_ts "__SCW_GLOBAL"
}
scw_get_global_ts() {
    scw_get_ts "__SCW_GLOBAL"
}
scw_get_repository_name() {
    REPOSITORY_URL="$1"
    if echo -n "$REPOSITORY_URL" | grep -E ":[^\.]+\.git$" 1>/dev/null; then
        echo -n "$REPOSITORY_URL" | cut -d: -f2 | sed 's/\.git$//'
    elif expr "$REPOSITORY_URL" : "http" 1>/dev/null; then
        echo -n "$REPOSITORY_URL" | awk -F/ '{print $(NF-1) "/" $(NF)}'
    fi
}
scw_satis_verify_repository_exists() {
    REPOSITORY_NAME=`scw_get_repository_name "$1"`
    if [ "`cat /etc/satis/satis.json | jq '.repositories[] | select(.url | contains("'"$REPOSITORY_NAME"'")) | .url' | wc -c`" == "0" ]; then
        scw_log_error "Repository $1 does not exist in this Satis repository"
        exit 0
    fi
}
scw_wait() {
    /satis-server/bin/ts -nf $*
}