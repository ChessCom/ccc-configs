FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/Ciekce/Stormphrax/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch morelayers_16_sqrrelu https://github.com/Ciekce/Stormphrax && \
    cd Stormphrax && \
    wget https://github.com/Ciekce/stormphrax-nets/releases/download/net037_dev/net037_dev.nnue && \
    make native CXX=clang++ COMMIT_HASH=on EVALFILE=net037_dev.nnue && \
    mv stormphrax-*-native stormphrax

CMD [ "./Stormphrax/stormphrax" ]
