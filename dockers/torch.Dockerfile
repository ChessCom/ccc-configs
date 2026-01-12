FROM alpine:3.22

ARG DEBIAN_FRONTEND=noninteractive

RUN apk add --no-cache clang compiler-rt llvm make git python3-dev py3-pip build-base numactl-dev && \
    pip install --upgrade pip --break-system-packages && \
    pip install py-cpuinfo requests numpy --break-system-packages

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN clang++ --version

RUN --mount=type=secret,id=TORCHBENCH_USER \
    --mount=type=secret,id=TORCHBENCH_PASS \
    --mount=type=secret,id=TORCH_GIT_TOKEN \
    git clone --branch master https://$(cat /run/secrets/TORCH_GIT_TOKEN)@github.com/ChessCom/TorchDev.git && \
    cd TorchDev && \
    OPENBENCH_USERNAME=$(cat /run/secrets/TORCHBENCH_USER) \
    OPENBENCH_PASSWORD=$(cat /run/secrets/TORCHBENCH_PASS) \
    python3 make.py pgo --exe=torch --cxx clang++ -j --numa

CMD [ "./TorchDev/torch" ]
