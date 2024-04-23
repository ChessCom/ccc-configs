FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/connormcmonigle/seer-nnue/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://github.com/connormcmonigle/seer-nnue && \
    cd seer-nnue && \
    $(grep "wget -O eval.bin https://github.com/connormcmonigle/seer-training/" README.md |head) && \
    cd build && \
    make -j pgo EVALFILE=../eval.bin

CMD [ "./seer-nnue/build/seer" ]
