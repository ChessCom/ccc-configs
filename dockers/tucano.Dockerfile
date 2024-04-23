FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/alcides-schulz/Tucano/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/alcides-schulz/Tucano.git && \
    cd Tucano/src && \
    make -j avx2

# Move the latest NNUE file to the expected location
RUN git clone https://github.com/alcides-schulz/TucanoNets && \
    mv TucanoNets/* Tucano/src

CMD [ "./Tucano/src/tucano_avx2" ]
