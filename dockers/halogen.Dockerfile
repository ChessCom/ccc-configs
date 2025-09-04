FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone --branch master https://github.com/KierenP/Halogen.git && \
    cd Halogen/src && \
    make pgo EXE=Halogen-master -j EXTRA_CXXFLAGS='-DTOURNAMENT_MODE' EXTRA_LDFLAGS='-lnuma'


CMD [ "./Halogen/src/Halogen-master" ]
