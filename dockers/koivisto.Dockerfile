FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN git clone https://github.com/Luecx/Koivisto && \
    cd Koivisto/src_files && \
    make -j EXE=Koivisto

CMD [ "./Koivisto/src_files/Koivisto" ]
