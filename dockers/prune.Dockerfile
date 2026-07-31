FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld libnuma-dev

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from dev
RUN git clone --branch dev --depth 1 https://github.com/tgirolami09/Prune && \
    cd Prune/core && \
    make -j EXE=prune NUMA=true

CMD [ "./Prune/core/prune" ]
