FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Download the Main Network
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
       $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Stockfish/tch177-3072-49.2x3072.sf/ \
       --output tch177-3072-49.2x3072.sf

# Download the Secondary Network
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
       $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Stockfish/tch161-128-45.2x128.sf/ \
       --output tch161-128-45.2x128.sf

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from L1-256
RUN git clone --branch net_swap https://github.com/AndyGrant/Stockfish.git && \
    cd Stockfish/src && \
    mv ../../tch*.sf . && \
    make -j profile-build ARCH=x86-64-avx2 COMP=gcc

CMD [ "./Stockfish/src/stockfish" ]
