ARG ALPINE_VERSION=3.10

FROM alpine:${ALPINE_VERSION}
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
LABEL \
    org.opencontainers.image.authors="" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.url="https://github.com/" \
    org.opencontainers.image.documentation="https://github.com/" \
    org.opencontainers.image.source="https://github.com/" \
    org.opencontainers.image.title="PIA client" \
    org.opencontainers.image.description="VPN client to tunnel to private internet access servers using OpenVPN, IPtables, DNS over TLS and Alpine Linux"
ENV USER= \
    PASSWORD= \
    ENCRYPTION=strong \
    PROTOCOL=udp \
    REGION="CA Montreal" \
    NONROOT=yes \
    DOT=on \
    BLOCK_MALICIOUS=off \
    BLOCK_NSA=off \
    UNBLOCK= \
    EXTRA_SUBNETS= \
    PORT_FORWARDING=off \
    PORT_FORWARDING_STATUS_FILE="/forwarded_port" \
    TZ=
ENTRYPOINT /entrypoint.sh
EXPOSE 8888/tcp 8388/tcp 8388/udp
HEALTHCHECK --interval=3m --timeout=3s --start-period=20s --retries=1 CMD /healthcheck.sh
RUN apk add -q --progress --no-cache --update openvpn wget ca-certificates iptables unzip jq tzdata && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    wget -q https://www.privateinternetaccess.com/openvpn/openvpn.zip \
    https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip \
    https://www.privateinternetaccess.com/openvpn/openvpn-tcp.zip \
    https://www.privateinternetaccess.com/openvpn/openvpn-strong-tcp.zip && \
    mkdir -p /openvpn/target && \
    unzip -q openvpn.zip -d /openvpn/udp-normal && \
    unzip -q openvpn-strong.zip -d /openvpn/udp-strong && \
    unzip -q openvpn-tcp.zip -d /openvpn/tcp-normal && \
    unzip -q openvpn-strong-tcp.zip -d /openvpn/tcp-strong && \
    apk del -q --progress --purge unzip && \
    rm -rf /*.zip /var/cache/apk/* && \
    adduser nonrootuser -D -H --uid 1000 
COPY entrypoint.sh healthcheck.sh portforward.sh /
RUN chmod 500 /entrypoint.sh /healthcheck.sh /portforward.sh
