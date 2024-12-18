FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break if there have been new commits
ADD https://api.github.com/repos/mhouppin/stash-bot/git/refs/heads/master /.git-hashref

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/mhouppin/stash-bot.git && \
    cd stash-bot && \
    CC=gcc ./utils/build.sh

CMD [ "./stash-bot/src/stash-bot" ]
