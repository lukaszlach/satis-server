#!/usr/bin/env sh
if [ "$1" == "help" ]; then
    /satis-server/bin/scw-help.sh
    exit 0
fi
if [ "$1" == "satis-server" ] && [ ! -f /etc/satis/satis.json ]; then
    (
        cd /etc/satis
        satis init --name=satis-server --homepage=http://satis-server:8080/ --no-ansi -vvv -n
    )
fi
set -e
if [ "$SATIS_REBUILD_AT" ]; then
    echo "$SATIS_REBUILD_AT /usr/local/bin/satis-build-all" > /tmp/crontab
    crontab /tmp/crontab
    rm -f /tmp/crontab
    crond -b
fi
mkdir -p /etc/satis-server /var/satis-server
if [ -f /etc/satis-server/ssh/id_rsa ]; then
    mkdir -p /root/.ssh/satis-server
    cp -R /etc/satis-server/ssh/* /root/.ssh/satis-server
    chmod 700 /root/.ssh/satis-server/*
    echo "IdentityFile ~/.ssh/satis-server/id_rsa" >> /etc/ssh/ssh_config
fi
set +e
exec /sbin/tini -g -s -- /satis/bin/docker-entrypoint.sh "$@"