FROM nvidia/cuda:12.4.0-devel-ubuntu22.04 as builder

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
    git clone https://github.com/Ergodice/lc0.git && \
    cd lc0 && \
    git checkout master && \
    git submodule update --remote && \
    pip3 install virtualenv meson && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    git clone -b 2.11 https://github.com/NVIDIA/cutlass.git /tmp/cutlass && \
    INSTALL_PREFIX=/root/.local ./build.sh release \
        -Dcutlass=true \
        -Dcutlass_include=/tmp/cutlass/include \
        -Dmalloc=tcmalloc \
        -Db_lto=true \
        -Ddefault_library=static

FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

ARG TZ='America/Los_Angeles'

WORKDIR /root

COPY --from=builder /root/lc0/build/release /root/lc0

RUN echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y \
    wget \
    libgomp1 \
    libprotobuf-dev \
    libgoogle-perftools-dev && \
    apt purge wget git -y && \
    apt autoclean

CMD [ "/root/lc0/lc0",  "--show-hidden" ]