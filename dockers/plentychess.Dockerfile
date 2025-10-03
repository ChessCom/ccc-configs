FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch threat-inputs-ccc --depth 1 https://github.com/Yoshie2000/PlentyChess/ && \
    cd PlentyChess && \
    make -j EXE=PlentyChess

CMD [ "./PlentyChess/PlentyChess" ]
