FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Determine the default Network via the API
RUN echo $(curl http://chess.grantnet.us/api/networks/Ethereal/ |jq -r '.default.sha256') >> /.default-net

# Download the default Network, using GRANTNET_USER and GRANTNET_PASS secrets
RUN --mount=type=secret,id=GRANTNET_USER --mount=type=secret,id=GRANTNET_PASS \
    curl -X POST \
       -F "username=$(cat /run/secrets/GRANTNET_USER)" \
       -F "password=$(cat /run/secrets/GRANTNET_PASS)" \
       http://chess.grantnet.us/api/networks/Ethereal/$(cat /.default-net)/ \
       --output ethy.default.std.nn

# Clone and build from master
RUN git clone https://github.com/AndyGrant/Ethereal.git && \
    cd Ethereal/src && \
    make -j EVALFILE=../../ethy.default.std.nn

CMD [ "./Ethereal/src/Ethereal" ]