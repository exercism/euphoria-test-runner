FROM ubuntu:bionic
LABEL maintainer="Greg Haberek <ghaberek@gmail.com> and Bruce Axtens <bruce.axtens@gmail.com>"
ADD https://github.com/OpenEuphoria/euphoria/releases/download/4.1.0/euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz /tmp
ENV PATH=/usr/local/euphoria-4.1.0-Linux-x64/bin:$PATH
RUN apt-get update && \
    apt-get install jq coreutils -y && \ 
    apt-get purge --auto-remove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    tar xzvf /tmp/euphoria-4.1.0-Linux-x64-57179171dbed.tar.gz -C /usr/local 

WORKDIR /opt/test-runner
COPY . .
#ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
ENTRYPOINT ["eui /opt/test-runner/bin/run.ex"]
