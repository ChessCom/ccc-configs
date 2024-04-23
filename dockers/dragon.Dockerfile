FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Dragon requires this very specific version of Eigen
RUN git clone https://gitlab.com/libeigen/eigen.git && \
    cd eigen && \
    git checkout fdf2ee62 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make install

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
# ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Determine the default Network via the API
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    echo $(curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
        $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Dragon/ |jq -r '.default.name') >> /.default-net

# Download the default Network, using TORCHBENCH_USER and TORCHBENCH_PASS secrets
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
       $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Dragon/$(cat /.default-net)/ \
       --output dragon.knn

# Build from source, without embedding a Network file
RUN --mount=type=secret,id=DRAGON_GIT_TOKEN \
    git clone https://$(cat /run/secrets/DRAGON_GIT_TOKEN)@github.com/ChessCom/komodo.git && \
    cd komodo && \
    ./build_dragon.sh --avx2 && \
    mv build_dragon/dragon ../dragon-avx2-popcnt

CMD [ "./dragon-avx2-popcnt" ]
