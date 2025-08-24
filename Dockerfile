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

RUN apt-get install -q -y \
      xvfb \
      nodejs \
      npm \
      fuse \
      net-tools

RUN apt-get install -y -q \
      at-spi2-common \
      fontconfig \
      fonts-freefont-ttf \
      fonts-ipafont-gothic \
      fonts-liberation \
      fonts-noto-color-emoji \
      fonts-tlwg-loma-otf \
      fonts-unifont \
      fonts-wqy-zenhei \
      libasound2-data \
      libasound2t64 \
      libatk-bridge2.0-0t64 \
      libatk1.0-0t64 \
      libatspi2.0-0t64 \
      libavahi-client3 \
      libavahi-common-data \
      libavahi-common3 \
      libcairo2 \
      libcups2t64 \
      libdatrie1 \
      libfribidi0 \
      libgraphite2-3 \
      libharfbuzz0b \
      libnspr4 \
      libnss3 \
      libpango-1.0-0 \
      libthai-data \
      libthai0 \
      libxcb-render0 \
      libxdamage1 \
      libxkbcommon0 \
      xfonts-cyrillic \
      xfonts-scalable

RUN apt-get install -q -y python3 && \
    sh /uv-installer.sh && rm /uv-installer.sh && \
    uv venv venv --python 3.13 && . ./venv/bin/activate && \
    uv pip install --upgrade setuptools && \
    uv pip install wheel build typing-extensions pylint pyright ruff ty

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

RUN wget -qO- "${TOOLCHAIN_URL}" | tar -xJf - && arm-none-eabi-gcc --version && avr-gcc --version

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
    cp -r "${EXTRACTED_DIR}"/* /usr/local/ && \
    rm -rf "${EXTRACTED_DIR}" "${NVIM_FILENAME}" && \
    nvim --version

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y docker-ce-cli && docker --version

RUN rm -rf /var/lib/apt/lists/*
