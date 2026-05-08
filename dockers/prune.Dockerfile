FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from dev
RUN git clone --branch dev --depth 1 https://github.com/tgirolami09/Prune && \
    cd Prune/core && \
    make -j EXE=prune

CMD [ "./Prune/core/prune" ]
