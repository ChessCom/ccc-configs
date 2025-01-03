FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install jq

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/jhonnold/berserk/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://github.com/jhonnold/berserk.git && \
    cd berserk/src && \
    git checkout main && \
    make build -j ARCH=native EXE=berserk CC=clang

CMD [ "./berserk/src/berserk" ]
