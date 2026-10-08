FROM ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7

ARG OPEN_EUPHORIA_ARCH=Linux-x64
ARG OPEN_EUPHORIA_VERSION=4.1.0
ARG OPEN_EUPHORIA_SHA=57179171dbed

RUN apt-get update && \
    apt-get install --yes --no-install-recommends curl ca-certificates && \
    apt-get purge --auto-remove --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN filename="euphoria-${OPEN_EUPHORIA_VERSION}-${OPEN_EUPHORIA_ARCH}-${OPEN_EUPHORIA_SHA}.tar.gz" && \
    curl -L -O "https://github.com/OpenEuphoria/euphoria/releases/download/${OPEN_EUPHORIA_VERSION}/${filename}" && \
    tar -xzf "${filename}" -C /usr/local && \
    rm "${filename}" && \
    cd /usr/local/bin && \
    find "/usr/local/euphoria-${OPEN_EUPHORIA_VERSION}-${OPEN_EUPHORIA_ARCH}/bin" -type f -executable -exec ln -s {} \; && \
    eui --version

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
