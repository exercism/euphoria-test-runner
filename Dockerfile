FROM ubuntu:24.04

ARG OPEN_EUPHORIA_ARCH=Linux-x64
ARG OPEN_EUPHORIA_VERSION=4.1.0
ARG OPEN_EUPHORIA_SHA=57179171dbed

RUN apt update && apt install -y curl

RUN filename="euphoria-${OPEN_EUPHORIA_VERSION}-${OPEN_EUPHORIA_ARCH}-${OPEN_EUPHORIA_SHA}.tar.gz" && \
    curl -L -O "https://github.com/OpenEuphoria/euphoria/releases/download/${OPEN_EUPHORIA_VERSION}/${filename}" && \
    tar -xzf "${filename}" -C /usr/local && \
    cd /usr/local/bin && \
    find "/usr/local/euphoria-${OPEN_EUPHORIA_VERSION}-${OPEN_EUPHORIA_ARCH}/bin" -type f -executable -exec ln -s {} \; && \
    eui --version

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
