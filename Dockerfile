FROM ubuntu:bionic
LABEL maintainer="Greg Haberek <ghaberek@gmail.com>"
ADD euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz /usr/local/
ENV PATH=/usr/local/euphoria-4.1.0-Linux-x64/bin:$PATH
RUN apt-get update && \
    apt-get install jq coreutils -y && \ 
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/test-runner
COPY . .
#ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
ENTRYPOINT ["/usr/local/bin/eui /opt/test-runner/bin/run.ex"]
#ENTRYPOINT ["bash"]
