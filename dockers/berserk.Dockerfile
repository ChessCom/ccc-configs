FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Download the default Network, using GRANTNET_USER and GRANTNET_PASS secrets
RUN --mount=type=secret,id=GRANTNET_USER --mount=type=secret,id=GRANTNET_PASS \
    curl -X POST \
       -F "username=$(cat /run/secrets/GRANTNET_USER)" \
       -F "password=$(cat /run/secrets/GRANTNET_PASS)" \
       http://chess.grantnet.us/api/networks/Berserk/9B84C340/ \
       --output berserk-9b84c340af7e.nn

# Clone and build from main
RUN git clone https://github.com/jhonnold/berserk.git && \
    cd berserk/src && \
    git checkout main && \
    mv ../../berserk-9b84c340af7e.nn . && \
    make pgo -j ARCH=native EXE=berserk CC=clang

CMD [ "./berserk/src/berserk" ]
