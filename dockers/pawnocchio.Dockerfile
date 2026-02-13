FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

ENV ZIG_VERSION=0.15.2
ENV ZIG_ARCH=x86_64-linux
ENV ZIG_HOME=/opt/zig
ENV PATH=${ZIG_HOME}:${PATH}

RUN apt-get install -y ca-certificates xz-utils

RUN curl -L https://ziglang.org/download/${ZIG_VERSION}/zig-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz | tar -xJ && \
    mv zig-${ZIG_ARCH}-${ZIG_VERSION} ${ZIG_HOME}

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --branch main https://github.com/JonathanHallstrom/pawnocchio && \
    cd pawnocchio && \
    git submodule update --init --depth 1 && \
    make

CMD [ "./pawnocchio/pawnocchio" ]
