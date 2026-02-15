FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt-get -y install git make cmake wget curl gcc g++ clang llvm lld patch

# ------------------------------------------------------------------------------

# Force the cache to break, using CACHE_BUST = $(date +%s)
ARG CACHE_BUST

# ------------------------------------------------------------------------------

# Clone and build from master
RUN git clone https://github.com/official-stockfish/Stockfish.git -b 253aaefb
RUN <<EOF patch -p1 Stockfish/src/evaluate.h
--- a/src/evaluate.h
+++ b/src/evaluate.h
@@ -33,7 +33,7 @@ namespace Eval {
 // for the build process (profile-build and fishtest) to work. Do not change the
 // name of the macro or the location where this macro is defined, as it is used
 // in the Makefile/Fishtest.
-#define EvalFileDefaultNameBig "nn-3dd094f3dfcf.nnue"
+#define EvalFileDefaultNameBig "abcd.nnue"
 #define EvalFileDefaultNameSmall "nn-37f18f62d772.nnue"
 
 namespace NNUE {
EOF

RUN curl -L https://github.com/Bycclin/abcd/releases/download/n1/abcd-g.nine.nnue -o Stocjfish/src/abcd.nnue
RUN cd Stockfish/src && \
    make -j profile-build ARCH=x86-64-avx2 COMP=gcc && \
    mv Stockfish abcd

CMD [ "./Stockfish/src/stockfish" ]
