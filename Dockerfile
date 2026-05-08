FROM ubuntu:24.04@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b

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
    rm -f "${filename}" && \
    cd /usr/local/bin && \
    find "/usr/local/euphoria-${OPEN_EUPHORIA_VERSION}-${OPEN_EUPHORIA_ARCH}/bin" -type f -executable -exec ln -s {} \; && \
    eui --version

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
