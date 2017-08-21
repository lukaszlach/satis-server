#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "" ]; then
    scw_log_error "Repository URL was not passed as first parameter"
    exit 0
fi
REPOSITORY_URL="$1"
scw_satis_verify_repository_exists "$REPOSITORY_URL"

SATIS_JSON=`cat /etc/satis/satis.json | jq '.repositories[] |= del(select(.url == "'"$REPOSITORY_URL"'")) | del(.repositories[] | select(. == null))'`
echo "$SATIS_JSON" > /etc/satis/satis.json
scw_log "Successfully removed $REPOSITORY_URL, rebuild your repository"