FROM ubuntu:rolling
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive

RUN add-apt-repository universe && \
    apt-get update && \
    apt-get install -q -y \
      apt-utils \
      software-properties-common && \
    apt-get upgrade -y

RUN apt-get install -q -y \
      ca-certificates \
      git \
      gcc \
      g++ \
      clang \
      docker \
      gcc-multilib \
      g++-multilib \
      binutils-dev \
      python3-pip \
      cmake \
      ninja-build \
      wget \
      bzip2 && \
    apt-get clean

RUN wget -qO- https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 | tar -xj

ENV PATH "/work/gcc-arm-none-eabi-10.3-2021.10/bin:$PATH"

RUN arm-none-eabi-gcc --version

RUN python3 -m pip install --upgrade pip setuptools && \
    python3 -m pip install \
      wheel \
      pylint
