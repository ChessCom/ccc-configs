FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://github.com/jhonnold/berserk.git && \
    cd berserk/src && \
    git checkout main && \
    make pgo -j ARCH=native EXE=berserk CC=clang

CMD [ "./berserk/src/berserk" ]
