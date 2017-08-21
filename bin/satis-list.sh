#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "-s" ]; then
    SHORT_ROW=1
fi
scw_print_row() {
    if [ "$SHORT_ROW" ]; then
        printf "%-35s\t%s\n" "$1" "$3"
    else
        printf "%-35s\t%-50s\t%s\n" "$1" "$2" "$3"
    fi
}
scw_print_repository_row() {
    REPOSITORY_URL="$1"
    PACKAGE_NAME=`scw_get_repository_name "$REPOSITORY_URL"`
    scw_print_row "$PACKAGE_NAME" "$REPOSITORY_URL" "`scw_get_visible_ts "$REPOSITORY_URL"`"
}
scw_print_row "PACKAGE NAME" "PACKAGE URL" "LAST BUILT"
for REPOSITORY in `cat /etc/satis/satis.json | jq -r .repositories[].url`; do
    scw_print_repository_row "$REPOSITORY"
done