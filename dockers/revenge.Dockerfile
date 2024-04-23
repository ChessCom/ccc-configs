FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt-get -y install p7zip-full

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN --mount=type=secret,id=REVENGE_URL \
    wget $(cat /run/secrets/REVENGE_URL)

RUN 7z x Revenge_CCC.7z -o.

CMD [ "./Revenge_linux_avx2" ]
