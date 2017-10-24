#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
if [ "$1" == "" ]; then
    scw_log_error "Repository URL was not passed as first parameter"
    exit 0
fi
REPOSITORY_URL="$1"
scw_satis_verify_repository_exists "$REPOSITORY_URL"
PACKAGE_NAME=`scw_get_repository_name "$REPOSITORY_URL"`
PACKAGE_INFO=`cat /etc/satis/output/include/*.json | jq -r '.packages."'"$PACKAGE_NAME"'"'`
PACKAGE_RELEASES=`echo "$PACKAGE_INFO" | jq -r 'keys | .[]' | tr '\n' ';' | sed -e 's/;/, /g' -e 's/, $//'`
PACKAGE_DESCRIPTION=`echo "$PACKAGE_INFO" | jq -r '."dev-master".description | select (.!=null)'`
PACKAGE_HOMEPAGE=`echo "$PACKAGE_INFO" | jq -r '."dev-master".homepage | select (.!=null)'`
PACKAGE_AUTHORS=`echo "$PACKAGE_INFO" | jq -r '."dev-master".authors | .[].name' 2>/dev/null | tr '\n' ';' | sed -e 's/;/, /g' -e 's/, $//'`

echo "Package: $PACKAGE_NAME"
echo "Description: $PACKAGE_DESCRIPTION"
echo "Authors: $PACKAGE_AUTHORS"
echo "Releases: $PACKAGE_RELEASES"
echo "Homepage: $PACKAGE_HOMEPAGE"
echo "Last built: `scw_get_visible_ts "$REPOSITORY_URL"`"