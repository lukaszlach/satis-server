#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
scw_header
satis --no-ansi -V
composer --no-ansi -V
php -v | head -n 1
webhook -version