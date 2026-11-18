FROM nvidia/cuda:12.9.2-base-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

WORKDIR /root

RUN apt-get update && \
    apt-get install -y git curl ca-certificates build-essential && \
    apt-get clean

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN git clone --branch ccc-2026-11-11 https://github.com/GilliamWong/chess-transformer && \
    cd chess-transformer && \
    engine/linux/build.sh && \
    rm -rf /root/.cache/uv /root/.cargo /root/.rustup

CMD [ "/root/chess-transformer/engine/linux/engine.sh" ]
