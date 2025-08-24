FROM ubuntu:rolling
WORKDIR /work

ARG DEBIAN_FRONTEND=noninteractive
ARG TOOLCHAIN_ARCH

ARG TOOLCHAIN_VERSION=14.2.rel1
ARG TOOLCHAIN_FILENAME=arm-gnu-toolchain-${TOOLCHAIN_VERSION}-${TOOLCHAIN_ARCH}-arm-none-eabi
ARG TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu/${TOOLCHAIN_VERSION}/binrel/${TOOLCHAIN_FILENAME}.tar.xz

ENV PATH="/work/venv/bin:/work/${TOOLCHAIN_FILENAME}/bin:/root/.local/bin/:$PATH"

ADD https://astral.sh/uv/install.sh /uv-installer.sh

RUN apt-get update && \
    apt-get install -q -y apt-utils software-properties-common && \
    add-apt-repository universe && \
    apt-get upgrade -y && \
    apt-get install -q -y ca-certificates wget curl unzip

RUN apt-get install -q -y xvfb nodejs npm fuse

RUN apt-get install -q -y \
      git \
      gcc \
      g++ \
      clang \
      binutils-dev \
      gcc-avr \
      binutils-avr \
      avr-libc \
      cmake \
      ninja-build \
      bzip2 && \
    \
    if [ "$TOOLCHAIN_ARCH" = "x86_64" ]; then \
      apt-get install -q -y gcc-multilib g++-multilib; \
    fi && \
    \
    apt-get clean

RUN wget -qO- "${TOOLCHAIN_URL}" | tar -xJf - 

RUN apt-get install -q -y python3 && \
    sh /uv-installer.sh && rm /uv-installer.sh && \
    uv venv venv --python 3.13 && . ./venv/bin/activate && \
    uv pip install --upgrade setuptools && \
    uv pip install wheel build typing-extensions pylint pyright ruff ty

RUN arm-none-eabi-gcc --version && avr-gcc --version

RUN curl \
    -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage \
    -o nvim.appimage \
    && chmod u+x nvim.appimage \
    && mv nvim.appimage /usr/bin/nvim

RUN nvim --version

RUN npx playwright install chromium --with-deps
