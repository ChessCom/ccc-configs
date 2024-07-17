FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --branch L1-256 https://github.com/AndyGrant/Stockfish.git && \
    cd Stockfish/src && \
    make -j profile-build ARCH=x86-64-avx2 COMP=gcc

CMD [ "./Stockfish/src/stockfish" ]
