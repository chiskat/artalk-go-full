ARG ARTALK_VERSION=latest
FROM artalk/artalk-go:${ARTALK_VERSION}

RUN apk update && apk add libx11 gcompat

ARG TARGETARCH
ARG UPGIT_VERSION
RUN if [ -n "$UPGIT_VERSION" ]; then \
  UPGIT_PATH="download/${UPGIT_VERSION}"; \
  else \
  UPGIT_PATH="latest/download"; \
  fi && \
  wget -O /usr/bin/upgit "https://github.com/pluveto/upgit/releases/${UPGIT_PATH}/upgit_linux_${TARGETARCH}" && \
  chmod +x /usr/bin/upgit

ARG IPREGION_REF=master
RUN mkdir -p /ip2region
RUN wget -O /ip2region/ip2region.xdb "https://raw.githubusercontent.com/lionsoul2014/ip2region/${IPREGION_REF}/data/ip2region_v4.xdb"
