#!/usr/bin/env sh
MESSAGE="$1"
COLOR="${2:-green}"
curl -sSf -m 3 \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $HIPCHAT_TOKEN" \
    -d '{"color" : "'"$COLOR"'", "message_format" : "html", "message" : "'"$MESSAGE"'"}' \
    "${HIPCHAT_API}v2/room/$HIPCHAT_ROOM/notification"