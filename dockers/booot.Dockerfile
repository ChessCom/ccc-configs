FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN wget https://github.com/booot76/Booot-chess-engine/releases/download/7.4/booot7_linux_avx2 && \
    chmod +x booot7_linux_avx2 && \
    mv booot7_linux_avx2 booot

CMD [ "./booot" ]
