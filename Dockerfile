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

RUN set -e && \
    if [ "$TOOLCHAIN_ARCH" = "x86_64" ]; then \
      NVIM_FILENAME="nvim-linux-x86_64.tar.gz"; \
    elif [ "$TOOLCHAIN_ARCH" = "aarch64" ]; then \
      NVIM_FILENAME="nvim-linux-arm64.tar.gz"; \
    else \
      echo "Unsupported architecture for Neovim: $TOOLCHAIN_ARCH" && exit 1; \
    fi && \
    curl -fLO "https://github.com/neovim/neovim/releases/latest/download/${NVIM_FILENAME}" && \
    tar xzf "${NVIM_FILENAME}" && \
    EXTRACTED_DIR=$(basename "${NVIM_FILENAME}" .tar.gz) && \
    mv "${EXTRACTED_DIR}/bin/nvim" /usr/bin/ && \
    rm -rf "${EXTRACTED_DIR}" "${NVIM_FILENAME}" && \
    nvim --version

RUN npx playwright install chromium --with-deps
