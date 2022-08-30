FROM ubuntu:rolling
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive

ENV PATH "/work/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi/bin:$PATH"

RUN wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu/11.3.rel1/binrel/arm-gnu-toolchain-11.3.rel1-x86_64-arm-none-eabi.tar.xz | tar -xJvf - && \
    arm-none-eabi-gcc --version &&

RUN apt-get update && \
    apt-get install -q -y apt-utils software-properties-common && \
    add-apt-repository universe && \
    apt-get upgrade -y && \
    \
    apt-get install -q -y \
      ca-certificates \
      git \
      gcc \
      g++ \
      clang \
      docker \
      gcc-multilib \
      g++-multilib \
      binutils-dev \
      python3 \
      python3-pip \
      python3-venv \
      cmake \
      ninja-build \
      wget \
      bzip2 && \
    apt-get clean && \
    \
    \
    python3 -m venv venv && . ./venv/bin/activate && \
    python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install pylint
