#!/usr/bin/env sh
. /satis-server/bin/scw-functions.sh
scw_header
if [ ! -f /etc/satis/satis.json ]; then
    scw_log_error "/etc/satis/satis.json not found"
    exit 1
fi
cp -fr /satis-server/nginx/* /etc/nginx/
if [ -f /etc/satis-server/https/cert.pem ] && [ -f /etc/satis-server/https/key.pem ]; then
    sed 's/^#ssl//g; s/$SSL_PORT/'"$SSL_PORT"'/g' -i /etc/nginx/conf.d/*.conf
fi
if [ -f /etc/satis-server/htpasswd ]; then
    sed 's/^#auth//g' -i /etc/nginx/conf.d/*.conf
fi
if echo -n "$PROXY_IP" | grep -E "(\d{1,3}\.)+\d{1,3}/\d{1,2}" > /dev/null; then
	sed 's/^#proxy //g; s#$PROXY_IP#'"$PROXY_IP"'#g' -i /etc/nginx/conf.d/*.conf
fi
if echo -n "$API_ALLOW" | grep -E "(\d{1,3}\.)+\d{1,3}/\d{1,2}" > /dev/null; then
    sed 's/^#allow//g; s#$API_ALLOW#'"$API_ALLOW"'#g' -i /etc/nginx/conf.d/*.conf
fi
if [ ! -z "$PUSH_SECRET" ]; then
    sed 's/^#secret//g; s#$PUSH_SECRET#'"$PUSH_SECRET"'#g' -i /etc/nginx/conf.d/*.conf
fi
touch /tmp/error.html
nginx || exit 1
if [ "$1" == "" ]; then
    set -- -verbose -hotreload -port 9000 -urlprefix "api" -header X-Powered-By="Satis Server $SATIS_SERVER_VERSION" -hooks /etc/webhook/hooks.json
fi
exec webhook "$@"
