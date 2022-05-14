FROM cloudflare/cloudflared:2022.5.1 as cloudflared
FROM alpine:3.15.4

WORKDIR /project

RUN set -eux ; \
    apk add --no-cache \
        jq=1.6-r1 \
        py3-pip ; \
    pip3 --no-cache-dir install \
        "awscli" ; \
    \
    rm -rf ~/.cache

COPY --from=cloudflared /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=cloudflared /usr/local/bin/cloudflared /usr/local/bin

COPY entrypoint.sh /usr/local/bin/entrypoint

ENV NO_AUTOUPDATE="true"
ENV TUNNEL_TRANSPORT_LOGLEVEL="error"
ENV TUNNEL_LOGLEVEL="info"
ENV TUNNEL_METRICS="localhost:2000"

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL maintainer="Oleksandr Ponomarov <ponomarov.aleksandr@gmail.com>" \
      org.label-schema.url="https://github.com/shmileee/docker-images/images/base/cloudflared-tunnel/" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.vcs-url="git@github.com:shmileee/docker-images.git" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-type="Git" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.description="cloudflared tunnel" \
      org.label-schema.usage="https://github.com/shmileee/docker-images/images/base/cloudflared-tunnel/README.md" \
      org.label-schema.schema-version="1.0" \
      com.shmileee.image-type="base"

HEALTHCHECK --interval=5s --retries=6 --timeout=3s CMD wget -q ${TUNNEL_METRICS}/ready -O -

ENTRYPOINT ["/usr/local/bin/entrypoint"]
