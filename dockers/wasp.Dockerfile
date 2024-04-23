FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Downloads found at: https://waspchess.com/wasp_downloads.html
RUN wget https://waspchess.com/wasp_downloads/Wasp_6.50/Wasp650-linux-avx && \
    mv Wasp650-linux-avx Wasp && \
    chmod +x Wasp

CMD [ "./Wasp" ]