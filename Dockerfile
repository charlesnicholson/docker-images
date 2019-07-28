FROM ubuntu:18.04
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y -q \
        ca-certificates \
        git \
        gcc \
        g++ \
        clang \
        gcc-multilib \
        g++-multilib \
        binutils-dev \
        python3-pip \
        cmake \
        ninja-build

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install pylint
