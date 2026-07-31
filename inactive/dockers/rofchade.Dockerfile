FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld

RUN apt update && apt-get -y install unzip python3-pip && pip3 install gdown

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

RUN --mount=type=secret,id=ROFCHADE_URL \
    gdown $(cat /run/secrets/ROFCHADE_URL) -O rofchade.zip

RUN unzip rofchade.zip && \
    mv rofChade rofchade.bin && chmod +x rofchade.bin

CMD [ "./rofchade.bin" ]
