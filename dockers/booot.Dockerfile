FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN wget https://github.com/booot76/Booot-chess-engine/releases/download/7.3/booot73_avx2_linux && \
    chmod +x booot73_avx2_linux && \
    mv booot73_avx2_linux booot

CMD [ "./booot" ]
