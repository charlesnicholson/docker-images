FROM ubuntu:rolling
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive

ENV PATH "/work/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH"

RUN apt-get update && \
    \
    apt-get install -q -y \
      apt-utils \
      software-properties-common && \
    \
    add-apt-repository universe && \
    \
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
    \
    apt-get clean && \
    \
    wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi.tar.xz | tar -xj && \
    \
    arm-none-eabi-gcc --version && \
    \
    python3 -m venv venv && \
    . ./venv/bin/activate && \
    \
    python -m pip install --upgrade pip setuptools wheel && \
    \
    python -m pip install pylint
