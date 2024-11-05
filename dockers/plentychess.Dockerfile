FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/Yoshie2000/PlentyChess/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch main --depth 1 https://github.com/Yoshie2000/PlentyChess/ && \
    cd PlentyChess && \
    make -j EXE=PlentyChess

CMD [ "./PlentyChess/PlentyChess" ]
