FROM ubuntu:rolling
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive
ARG TOOLCHAIN_ARCH

ARG TOOLCHAIN_VERSION=14.2.rel1
ARG TOOLCHAIN_FILENAME=arm-gnu-toolchain-${TOOLCHAIN_VERSION}-${TOOLCHAIN_ARCH}-arm-none-eabi
ARG TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/${TOOLCHAIN_VERSION}/binrel/${TOOLCHAIN_FILENAME}.tar.xz

ENV PATH="/work/${TOOLCHAIN_FILENAME}/bin:$PATH"

# Base packages
RUN apt-get update && \
    apt-get install -q -y apt-utils software-properties-common && \
    add-apt-repository universe && \
    apt-get upgrade -y && \
    apt-get install -q -y ca-certificates wget curl

# Download toolchain
RUN wget -qO- "${TOOLCHAIN_URL}" | tar -xJvf - && \
    arm-none-eabi-gcc --version

# Dev dependencies and Python setup
RUN apt-get install -q -y \
      git \
      gcc \
      g++ \
      clang \
      binutils-dev \
      python3 \
      python3-pip \
      python3-venv \
      cmake \
      ninja-build \
      bzip2 && \
    if [ "$TOOLCHAIN_ARCH" = "x86_64" ]; then \
      apt-get install -q -y gcc-multilib g++-multilib; \
    fi && \
    apt-get clean && \
    \
    python3 -m venv venv && . ./venv/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install typing-extensions pylint && python -m pylint --version

