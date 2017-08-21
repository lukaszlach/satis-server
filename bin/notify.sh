#!/usr/bin/env sh
# notify-vendor.sh <message> [gray|green|red]
if [ "$NOTIFY_HIPCHAT" == "1" ]; then
    /satis-server/bin/notify-hipchat.sh "$@"
fi
if [ "$NOTIFY_SLACK" == "1" ]; then
    /satis-server/bin/notify-slack.sh "$@"
fi