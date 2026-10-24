ARG ARTALK_VERSION=latest
FROM ubuntu:24.04 AS upgit

ARG TARGETARCH
ARG UPGIT_VERSION
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget unzip libgcc-s1
RUN if [ -n "$UPGIT_VERSION" ]; then \
  UPGIT_PATH="download/${UPGIT_VERSION}"; \
  else \
  UPGIT_PATH="latest/download"; \
  fi && \
  wget -O /tmp/upgit.zip "https://github.com/pluveto/upgit/releases/${UPGIT_PATH}/upgit_linux_${TARGETARCH}.zip" && \
  mkdir -p /opt/upgit/lib && \
  unzip -p /tmp/upgit.zip upgit > /opt/upgit/upgit && \
  rm /tmp/upgit.zip && \
  chmod +x /opt/upgit/upgit

RUN ldd /opt/upgit/upgit > /tmp/upgit-libs && \
  awk '$3 ~ /^\// { print $3 }' /tmp/upgit-libs | xargs -r cp -L -t /opt/upgit/lib && \
  cp -L /lib/*/ld-linux-*.so.* /opt/upgit/lib/ld.so

FROM artalk/artalk-go:${ARTALK_VERSION}

COPY --from=upgit /opt/upgit /opt/upgit
RUN printf '#!/bin/sh\nexec /opt/upgit/lib/ld.so --library-path /opt/upgit/lib /opt/upgit/upgit "$@"\n' > /usr/bin/upgit && \
  chmod +x /usr/bin/upgit && \
  upgit --version

ARG IPREGION_REF=master
RUN mkdir -p /ip2region
RUN wget -O /ip2region/ip2region.xdb "https://raw.githubusercontent.com/lionsoul2014/ip2region/${IPREGION_REF}/data/ip2region_v4.xdb"
