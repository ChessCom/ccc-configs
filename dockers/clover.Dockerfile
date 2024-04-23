FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/lucametehau/CloverEngine/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --depth 1 --branch master https://github.com/lucametehau/CloverEngine && \
    cd CloverEngine/src && \
    make -j EXE=Clover

CMD [ "./CloverEngine/src/Clover" ]
