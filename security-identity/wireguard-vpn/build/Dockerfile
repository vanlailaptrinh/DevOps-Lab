FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wireguard \
    iproute2 \
    iptables \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/wireguard

COPY --chmod=0755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]