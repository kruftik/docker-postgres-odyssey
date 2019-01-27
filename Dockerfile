FROM debian:stretch-slim as builder
MAINTAINER Dmitry Gadeev <dr.kruft@gmail.com>
# Version of https://github.com/yandex/odyssey/issues/29#issuecomment-401326964
# 

# ENV DEF_ODYSSEY_CONF /etc/odyssey/odyssey.conf

WORKDIR /tmp/

RUN set -ex \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libssl-dev \
    && git clone --depth 1 git://github.com/yandex/odyssey.git \
    && cd odyssey \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make

FROM debian:stretch-slim

ENV CONFDVERSION 0.16.0

RUN set -ex \
    && apt-get update \
    && apt-get install -y curl libssl1.1 \
    && curl -sSL -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFDVERSION}/confd-${CONFDVERSION}-linux-amd64 \
    && chmod +x /usr/local/bin/confd \
    && apt-get remove -y curl \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /tmp/odyssey/build/sources/odyssey /usr/local/bin/

ADD odyssey.tmpl /etc/confd/templates/
ADD confd.toml  /etc/confd/conf.d/

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 6432

ENV ODYSSEY_MAXCLIENTS 2048
ENV ODYSSEY_POSTGRES_HOST localhost
ENV ODYSSEY_POSTGRES_PORT 5432
ENV ODYSSEY_POSTGRES_POOL_MODE transaction
ENV ODYSSEY_POSTGRES_POOL_SIZE 32
ENV ODYSSEY_POSTGRES_POOL_TIMEOUT 500 # msec
ENV ODYSSEY_POSTGRES_POOL_TTL 45 # sec

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odyssey", "/opt/odyssey.conf"]
