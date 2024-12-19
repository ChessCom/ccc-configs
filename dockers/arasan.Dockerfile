FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install bc

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/jdart1/arasan-chess/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/jdart1/arasan-chess && \
    cd arasan-chess && \
    git submodule update --init --recursive && \
    cd src && \
    make -j CC=clang BUILD_TYPE=avx2 profiled

# Copy the init file and the Networks where they are expected
RUN cp arasan-chess/network/* arasan-chess/bin

CMD [ "./arasan-chess/bin/arasanx-64-avx2" ]
