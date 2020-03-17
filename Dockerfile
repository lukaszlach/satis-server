ARG WEBHOOK_VERSION
FROM alpine:3.7 as ts
ENV TS_VERSION 1.0

WORKDIR /tmp
RUN apk add -U wget make gcc linux-headers g++ && \
    wget http://vicerveza.homeunix.net/~viric/soft/ts/ts-${TS_VERSION}.tar.gz && \
    tar zxvf ts-${TS_VERSION}.tar.gz && \
    cd ts-${TS_VERSION}/ && \
    make && \
    mv ts /ts

FROM almir/webhook:${WEBHOOK_VERSION} as webhook

FROM composer/satis
ARG SATIS_SERVER_VERSION
LABEL maintainer="Łukasz Lach <llach@llach.pl>" \
      org.label-schema.name="satis-server" \
      org.label-schema.description="Satis Server" \
      org.label-schema.usage="https://github.com/lukaszlach/satis-server/blob/master/README.md" \
      org.label-schema.url="https://github.com/lukaszlach/satis-server" \
      org.label-schema.vcs-url="https://github.com/lukaszlach/satis-server" \
      org.label-schema.version="${SATIS_SERVER_VERSION:-dev-master}" \
      org.label-schema.schema-version="1.1"
ENV SATIS_SERVER_VERSION ${SATIS_SERVER_VERSION:-dev-master}
WORKDIR /satis-server

RUN apk -U add jq nginx tini && \
    rm -rf /var/cache/apk/* /etc/nginx/conf.d/* && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    mkdir -p /root/.ssh/satis-server /etc/webhook

ADD . .
COPY --from=webhook /usr/local/bin/webhook /satis-server/bin/webhook
COPY --from=ts /ts /satis-server/bin/ts

RUN ln -s /satis-server/webhook/hooks.json /etc/webhook/hooks.json && \
    ln -s /satis-server/bin/webhook /usr/local/bin/webhook && \
    ln -s /satis-server/bin/satis-server.sh /usr/local/bin/satis-server && \
    ln -s /satis-server/bin/satis-build.sh /usr/local/bin/satis-build && \
    ln -s /satis-server/bin/satis-build-all.sh /usr/local/bin/satis-build-all && \
    ln -s /satis-server/bin/satis-add.sh /usr/local/bin/satis-add && \
    ln -s /satis-server/bin/satis-remove.sh /usr/local/bin/satis-remove && \
    ln -s /satis-server/bin/satis-list.sh /usr/local/bin/satis-list && \
    ln -s /satis-server/bin/satis-show.sh /usr/local/bin/satis-show && \
    ln -s /satis-server/bin/satis-dump.sh /usr/local/bin/satis-dump && \
    ln -s /satis-server/bin/scw-version.sh /usr/local/bin/satis-server-version && \
    ln -s /satis-server/bin/scw-help.sh /usr/local/bin/satis-server-help && \
    ln -s /satis/bin/satis /usr/local/bin/satis && \
    chmod +x /satis-server/bin/*

EXPOSE 80/tcp 443/tcp
VOLUME /etc/satis /etc/satis-server /var/satis-server
HEALTHCHECK --interval=1m --timeout=10s \
  CMD ( curl -f http://localhost:80/ping && curl -f http://localhost:9000/api/ping ) || exit 1

ENTRYPOINT ["/sbin/tini", "-g", "--", "/satis-server/bin/docker-entrypoint.sh"]
CMD ["satis-server"]
