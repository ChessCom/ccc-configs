FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch master https://github.com/Bobingstern/Tarnished && \
    cd Tarnished && \
    make -j

CMD [ "./Tarnished/tarnished" ]
