FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --depth 1 --branch master https://github.com/lucametehau/CloverEngine && \
    cd CloverEngine/src && \
    make -j EXE=Clover

CMD [ "./CloverEngine/src/Clover" ]
