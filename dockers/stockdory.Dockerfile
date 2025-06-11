FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    lsb-release \
    software-properties-common \
    gnupg \
    curl \
    git \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    python3-pip \
    python3-venv \
    wget


# Install LLVM 20
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 20 && \
    rm -rf llvm.sh


# Set up LLVM environment
RUN ln -s /usr/bin/clang-20 /usr/bin/clang && \
    ln -s /usr/bin/clang++-20 /usr/bin/clang++


# Set environment variables for LLVM
ENV CC=clang
ENV CXX=clang++

# Clone StockDory
RUN git clone https://github.com/TheBlackPlague/StockDory

# Change to StockDory directory
WORKDIR /StockDory

# Run Makefile to build StockDory
RUN make CC=clang CXX=clang++ EXE=StockDory

# Launch StockDory
CMD ["./StockDory"]
