FROM ubuntu:18.04
MAINTAINER Charles Nicholson <charles.nicholson@gmail.com>
LABEL="Clang Linux"

RUN apt-get update && apt-get install \
        clang \
        binutils-dev \
        wget \
        cmake \
        ninja

CMD ["/bin/bash"]
