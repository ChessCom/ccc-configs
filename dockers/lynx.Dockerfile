FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        git make wget software-properties-common

RUN apt-get update && \
    add-apt-repository ppa:dotnet/backports && \
    apt-get update && \
    apt-get install -y \
        dotnet-sdk-10.0

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone --branch main --depth 1 https://github.com/lynx-chess/lynx.git && \
    cd lynx && \
    make

# Download CCC-specific configuration file
RUN wget https://github.com/lynx-chess/lynx-ccc/raw/main/appsettings.tournament.json && \
    mv appsettings.tournament.json lynx/artifacts/Lynx/

CMD [ "./lynx/artifacts/Lynx/Lynx.Cli" ]
