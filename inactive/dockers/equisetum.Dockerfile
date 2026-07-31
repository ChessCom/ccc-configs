FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone all nets and place alongside Equi. source
RUN git clone https://github.com/justNo4b/EquisetumNets

# Clone and build from main
RUN git clone https://github.com/justNo4b/Equisetum && \
    cp -r EquisetumNets/* Equisetum/ && \
    cd Equisetum && \
    make -j EXE=Equisetum

CMD [ "./Equisetum/Equisetum" ]
