FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/Adam-Kulju/Patricia/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://github.com/Adam-Kulju/Patricia.git && \
    cd Patricia/engine && \
    make -j EXE=patricia-main

CMD [ "./Patricia/engine/patricia-main" ]
