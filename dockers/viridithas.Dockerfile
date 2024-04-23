FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

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
ADD https://api.github.com/repos/cosmobobak/viridithas/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Downloads the latest "Release", and save it as "viridithas.nnue"
RUN curl -s "https://api.github.com/repos/cosmobobak/viridithas-networks/releases/latest" \
   | grep -o '"browser_download_url": "[^"]*' | awk -F'"' '{print $4}' | xargs -L 1 wget -O viridithas.nnue

# Clone and build from master
RUN git clone https://github.com/cosmobobak/viridithas && \
    cd viridithas && \
    EVALFILE=../viridithas.nnue RUSTFLAGS="-C target-cpu=native" cargo build --release --features syzygy,bindgen

CMD [ "./viridithas/target/release/viridithas" ]

