FROM ubuntu:18.04
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>

RUN apt-get update && apt-get install -y -q \
        git \
        gcc \
        g++ \
        clang \
        binutils-dev \
        multilib \
        python3 \
        cmake \
        ninja-build

CMD ["/bin/bash"]
