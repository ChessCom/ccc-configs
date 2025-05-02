FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch main --depth 1 https://github.com/aronpetko/integral.git && \
    cd integral && \
    make native CXX=g++ EXE=integral.bin

CMD [ "./integral/integral.bin" ]

