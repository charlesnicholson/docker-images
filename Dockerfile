FROM ubuntu:rolling
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive
ARG TOOLCHAIN_ARCH

ARG TOOLCHAIN_VERSION=14.2.rel1
ARG TOOLCHAIN_FILENAME=arm-gnu-toolchain-${TOOLCHAIN_VERSION}-${TOOLCHAIN_ARCH}-arm-none-eabi
ARG TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/${TOOLCHAIN_VERSION}/binrel/${TOOLCHAIN_FILENAME}.tar.xz

ENV PATH="/work/${TOOLCHAIN_FILENAME}/bin:/root/.local/bin/:$PATH"

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ADD https://astral.sh/uv/install.sh /uv-installer.sh

RUN apt-get update && \
    apt-get install -q -y apt-utils software-properties-common && \
    add-apt-repository universe && \
    apt-get upgrade -y && \
    apt-get install -q -y ca-certificates wget curl

RUN apt-get install -q -y \
      git \
      gcc \
      g++ \
      clang \
      binutils-dev \
      gcc-avr \
      binutils-avr \
      avr-libc \
      python3 \
      python3-pip \
      python3-venv \
      cmake \
      ninja-build \
      bzip2 && \
    \
    if [ "$TOOLCHAIN_ARCH" = "x86_64" ]; then \
      apt-get install -q -y gcc-multilib g++-multilib; \
    fi && \
    \
    apt-get clean && \
    \
    sh /uv-installer.sh && rm /uv-installer.sh && \
    uv venv venv --python 3.13 && . ./venv/bin/activate && \
    uv install --updgrade setuptools && \
    uv install wheel build typing-extensions pylint pyright ruff

RUN wget -qO- "${TOOLCHAIN_URL}" | tar -xJvf - && arm-none-eabi-gcc --version
RUN avr-gcc --version

