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

# # ------------------------------------------------------------------------------
#
# # Force the cache to break if there have been new commits
# ADD https://api.github.com/repos/codedeliveryservice/Reckless/git/refs/heads/main /.git-hashref
#
# # ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/codedeliveryservice/Reckless && \
    cd Reckless && \
    cargo rustc --release -- -C target-cpu=native && \
    make EXE=reckless

CMD [ "./Reckless/reckless" ]
