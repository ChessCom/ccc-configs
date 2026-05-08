FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Identify the most recently created tag in PZChessBot-Networks and download nnue.bin
RUN git clone https://github.com/kevlu8/PZChessBot-Networks && \
    cd PZChessBot-Networks && \
    LATEST_TAG=$(git for-each-ref --sort=-v:refname --format='%(refname:short)' refs/tags | head -1) && \
    wget -O ../nnue.bin "https://github.com/kevlu8/PZChessBot-Networks/releases/download/${LATEST_TAG}/nnue.bin"

# Clone and build from main
RUN git clone --branch main --depth 1 https://github.com/kevlu8/PZChessBot && \
    cp nnue.bin PZChessBot/nnue.bin && \
    cd PZChessBot && \
    make -j EXE=pzchessbot

CMD [ "./PZChessBot/pzchessbot" ]
