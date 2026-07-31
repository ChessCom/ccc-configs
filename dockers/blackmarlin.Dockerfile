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

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Download the Network, using GRANTNET_USER and GRANTNET_PASS secrets
RUN --mount=type=secret,id=GRANTNET_USER \
    --mount=type=secret,id=GRANTNET_PASS \
    curl -X POST \
       -F "username=$(cat /run/secrets/GRANTNET_USER)" \
       -F "password=$(cat /run/secrets/GRANTNET_PASS)" \
       https://chess.grantnet.us/api/networks/BlackMarlin/blackmarlin.bin/ --output default.bin

RUN ls -l -h default.bin && sha256sum default.bin

# Clone and build from master. The repo's LFS budget is exhausted, so skip the
# smudge filter, and swap in the network we downloaded above for the pointer file
RUN export GIT_LFS_SKIP_SMUDGE=1 && \
    git clone https://github.com/jnlt3/blackmarlin && \
    cd blackmarlin && \
    git checkout main && \
    git pull && \
    mv ../default.bin nn/default.bin && \
    sha256sum nn/default.bin && \
    make -j

CMD [ "./blackmarlin/BlackMarlin" ]
