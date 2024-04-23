FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Install Git-LFS
RUN wget https://github.com/git-lfs/git-lfs/releases/download/v3.4.0/git-lfs-linux-amd64-v3.4.0.tar.gz && \
    tar -xvf git-lfs-linux-amd64-v3.4.0.tar.gz && \
    cd git-lfs-3.4.0 && \
    ./install.sh && \
    git lfs install

# Force the cache to break if there is a new stable Rust version
ADD https://static.rust-lang.org/dist/channel-rust-stable.toml /.rust-stable

# Install Cargo, but we won't have cargo on the path
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh && \
    chmod +x rustup.sh && ./rustup.sh -y && \
    $HOME/.cargo/bin/rustup update

# Add Cargo to the path
ENV PATH="/root/.cargo/bin:$PATH"

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/dsekercioglu/blackmarlin/git/refs/heads/main /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/dsekercioglu/blackmarlin && \
    cd blackmarlin && \
    git checkout main && \
    git pull && \
    make -j

CMD [ "./blackmarlin/BlackMarlin" ]
