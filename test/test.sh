#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
scw_header

ensure_eq() {
    if [ "$1" != "$2" ]; then
        scw_log_error "'$1' does not match '$2'"
        exit 1;
    fi
}
ensure_neq() {
    if [ "$1" == "$2" ]; then
        scw_log_error "'$1' matches '$2'"
        exit 1;
    fi
}
scw_log "Running sh unit-tests..."
set -ex
# timestamp
UNIQUE_ID=`head -c 1024 /dev/urandom | md5sum | cut -d" " -f1`
ensure_eq "`scw_get_ts "$UNIQUE_ID"`" ""
scw_set_ts "$UNIQUE_ID"
ensure_neq "`scw_get_ts "$UNIQUE_ID"`" ""
ensure_neq "`scw_get_visible_ts "$UNIQUE_ID"`" ""
ensure_neq "`scw_get_visible_ts "$UNIQUE_ID"`" "never"
# global timestamp
scw_set_global_ts
ensure_neq "`scw_get_global_ts`" ""
# repository name
ensure_eq "`scw_get_repository_name "https://github.com/php-amqplib/php-amqplib"`" "php-amqplib/php-amqplib"
ensure_eq "`scw_get_repository_name "https://gitlab.server.com/php-amqplib/php-amqplib"`" "php-amqplib/php-amqplib"
ensure_eq "`scw_get_repository_name "git@github.com:php-amqplib/php-amqplib.git"`" "php-amqplib/php-amqplib"
ensure_eq "`scw_get_repository_name "git@gitlab.server.com:php-amqplib/php-amqplib.git"`" "php-amqplib/php-amqplib"
# files
test -f /etc/satis/satis.json
test -d /etc/satis-server
test -d /var/satis-server
test -f
test -f /satis/bin/docker-entrypoint.sh
test -f /satis-server/bin/docker-entrypoint.sh
test -f /satis-server/bin/webhook
[ ! "`find bin -type f ! -perm +111`" ] || { echo "Non-executable found in bin/"; exit 1; }
set +x
scw_log "Done"