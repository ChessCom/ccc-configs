FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/tryingsomestuff/Minic.git && \
    cd Minic && \
    git fetch && \
    git checkout $(git describe --tags --abbrev=0) && \
    git submodule update --init Fathom && \
    make -j

CMD [ "./Minic/Dist/Minic3/minic_dev_linux_x64" ]
