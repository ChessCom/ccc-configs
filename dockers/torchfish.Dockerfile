FROM alpine:3.18

ARG DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache clang compiler-rt llvm make git python3-dev py3-pip build-base numactl-dev && \
    pip install --upgrade pip && \
    pip install py-cpuinfo requests

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCH_GIT_TOKEN \
    git clone --branch master https://$(cat /run/secrets/TORCH_GIT_TOKEN)@github.com/ChessCom/TorchDev.git && \
    cd TorchDev && \
    OPENBENCH_USERNAME=$(cat /run/secrets/TORCHBENCH_USER) \
    OPENBENCH_PASSWORD=$(cat /run/secrets/TORCHBENCH_PASS) \
    python3 make.py pgo --exe=torch --cxx clang++ -j --numa --nn nn-e8bac1c07a5a.kxl --L1 3072

CMD [ "./TorchDev/torch" ]
