FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/Disservin/Smallbrain/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://github.com/Disservin/Smallbrain.git && \
    cd Smallbrain/src && \
    make -j pgo EXE=smallbrain

CMD [ "./Smallbrain/src/smallbrain" ]
