FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Determine the default Network via the API
RUN echo $(curl http://chess.grantnet.us/api/networks/Igel/ |jq -r '.default.sha256') >> /.default-net

# Download the default Network, using GRANTNET_USER and GRANTNET_PASS secrets
RUN --mount=type=secret,id=GRANTNET_USER --mount=type=secret,id=GRANTNET_PASS \
    curl -X POST \
       -F "username=$(cat /run/secrets/GRANTNET_USER)" \
       -F "password=$(cat /run/secrets/GRANTNET_PASS)" \
       http://chess.grantnet.us/api/networks/Igel/$(cat /.default-net)/ \
       --output igel.nn

# Clone and build from master
RUN git clone https://github.com/vshcherbyna/igel.git && \
    cd igel/src && \
    make -j EVALFILE=../../igel.nn

CMD [ "./igel/src/igel" ]
