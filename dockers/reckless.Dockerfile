FROM ubuntu:24.04

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

# Setup for PGO
RUN rustup component add llvm-tools && \
    cargo install cargo-pgo

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch main https://github.com/codedeliveryservice/Reckless && \
    cd Reckless && \
    cargo pgo instrument && \
    cargo pgo run -- bench && \
    cargo pgo optimize && \
    mv target/$(rustc --print host-tuple)/release/reckless reckless

CMD [ "./Reckless/reckless" ]
