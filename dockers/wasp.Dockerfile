FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Downloads found at: https://waspchess.stanback.net/wasp_downloads.html
RUN wget https://waspchess.stanback.net/wasp_downloads/Wasp_7.07/Wasp707-linux-avx && \
    mv Wasp707-linux-avx Wasp && \
    chmod +x Wasp

CMD [ "./Wasp" ]
