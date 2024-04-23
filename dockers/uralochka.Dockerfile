FROM silkeh/clang:16-bullseye

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl

# ------------------------------------------------------------------------------

# Install Git-LFS
RUN wget https://github.com/git-lfs/git-lfs/releases/download/v3.4.0/git-lfs-linux-amd64-v3.4.0.tar.gz && \
    tar -xvf git-lfs-linux-amd64-v3.4.0.tar.gz && \
    cd git-lfs-3.4.0 && \
    ./install.sh && \
    git lfs install

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from main
RUN git clone https://gitlab.com/freemanzlat/uralochka3 && \
    cd uralochka3 && \
    git pull origin main && \
    git lfs pull && \
    chmod +x utils/build_ur3.sh && \
    ./utils/build_ur3.sh linux 1 ../src build "../nn/*.nn" "-DCMAKE_BUILD_TYPE=Release -DARCH=native -DUSE_POPCNT=1 -DLINUX_STATIC=1" && \
    mv build/Uralochka3 ../uralochka

CMD [ "./uralochka" ]
