FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/Alex2262/AltairChessEngine/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/Alex2262/AltairChessEngine/ && \
    cd AltairChessEngine && \
    make native=1

CMD [ "./AltairChessEngine/Altair" ]
