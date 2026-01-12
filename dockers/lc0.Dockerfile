FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
    python3 \
    ninja-build \
    python3-pip \
    zlib1g-dev \
    ocl-icd-libopencl1 \
    libgoogle-perftools-dev \
    wget \
    git \
    python3-venv

RUN PATH="/$HOME/.local/bin:$PATH" && \
    git clone https://github.com/Menkib64/lc0/ && \
    cd lc0 && \
    git checkout ccc-cutlass-cuda-graphs && \
    git submodule update --remote && \
    pip3 install virtualenv && \
    pip3 install meson && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    git clone -b 2.11 https://github.com/NVIDIA/cutlass.git /tmp/cutlass && \
    INSTALL_PREFIX=/root/.local ./build.sh release \
        -Dcutlass=true \
        -Dcutlass_include=/tmp/cutlass/include \
        -Dmalloc=tcmalloc \
        -Db_lto=true \
        -Ddefault_library=static \
        -Ddefault_search="dag-preview" \
        -Dcc_cuda=80

FROM nvidia/cuda:12.8.0-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ARG TZ='America/Los_Angeles'

WORKDIR /root

COPY --from=builder /root/lc0/build/release /root/lc0

RUN echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y wget libgomp1 libprotobuf-dev libgoogle-perftools-dev && \
    apt purge git -y && \
    apt autoclean

WORKDIR /root/lc0

RUN wget https://storage.lczero.org/files/networks-contrib/BT4-1024x15x32h-swa-6147500-policytune-332.pb.gz

CMD [ "/root/lc0/./lc0", "--show-hidden" ]