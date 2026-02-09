FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Determine the default Network via the API
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    echo $(curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
        $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Ethereal/ |jq -r '.default.name') >> /.default-net

# Download the default Network, using TORCHBENCH_USER and TORCHBENCH_PASS secrets
RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCHBENCH_SITE \
    curl -X POST \
       -F "username=$(cat /run/secrets/TORCHBENCH_USER)" \
       -F "password=$(cat /run/secrets/TORCHBENCH_PASS)" \
       $(cat /run/secrets/TORCHBENCH_SITE)/api/networks/Ethereal/$(cat /.default-net)/ \
       --output ethy.default.std.nn

# Clone and build from master
RUN git clone https://github.com/AndyGrant/Ethereal.git && \
    cd Ethereal/src && \
    make -j EVALFILE=../../ethy.default.std.nn

CMD [ "./Ethereal/src/Ethereal" ]