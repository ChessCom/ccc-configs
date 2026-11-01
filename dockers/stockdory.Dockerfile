FROM ghcr.io/theblackplague/stockdory:latest

ARG CACHE_BUST

RUN stockdory-entrypoint -- true

ENTRYPOINT ["/opt/stockdory-bin/StockDory"]
