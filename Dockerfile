FROM ubuntu:latest
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update && apt-get install -q \
        ca-certificates \
        git \
        gcc \
        g++ \
        clang \
        gcc-multilib \
        g++-multilib \
        binutils-dev \
        python3.9 \
        python3-pip \
        cmake \
        ninja-build

RUN python3 -m pip install --upgrade pip setuptools
RUN python3 -m pip install pylint
