# Reference:
# https://github.com/cvpaperchallenge/Ascender
# https://github.com/nerfstudio-project/nerfstudio

FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ARG USER_NAME=ncj
ARG GROUP_NAME=ncj
ARG UID=1000
ARG GID=1000

# Set compute capability for nerfacc and tiny-cuda-nn
# See https://developer.nvidia.com/cuda-gpus and limit number to speed-up build
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6 9.0+PTX"
ENV TCNN_CUDA_ARCHITECTURES=90;86;80;75;70;61;60
# Speed-up build for RTX 30xx
# ENV TORCH_CUDA_ARCH_LIST="8.6"
# ENV TCNN_CUDA_ARCHITECTURES=86
# Speed-up build for RTX 40xx
# ENV TORCH_CUDA_ARCH_LIST="8.9"
# ENV TCNN_CUDA_ARCHITECTURES=89

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:/home/${USER_NAME}/.local/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV LIBRARY_PATH=${CUDA_HOME}/lib64/stubs:${LIBRARY_PATH}

# apt install by root user
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libegl1-mesa-dev \
    libgl1-mesa-dev \
    libgles2-mesa-dev \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    python-is-python3 \
    python3.10-dev \
    python3-pip \
    wget \
    libxrender1 \
    libxi6 \
    libxkbcommon-x11-0 \
    sudo \
    htop \
    nvtop \
    tmux \
    vim \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Change user to non-root user
RUN groupadd -g ${GID} ${GROUP_NAME} \
    && useradd -ms /usr/bin/bash -u ${UID} -g ${GID} ${USER_NAME} \
    && echo root:password | chpasswd \
    && echo ${USER_NAME}:password | chpasswd \
    && usermod -aG sudo ${USER_NAME} \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${USER_NAME}

RUN pip install --upgrade pip setuptools ninja
RUN pip install torch torchvision xformers --index-url https://download.pytorch.org/whl/cu121
# Install nerfacc and tiny-cuda-nn before installing requirements.txt
# because these two installations are time consuming and error prone
RUN pip install git+https://github.com/KAIR-BAIR/nerfacc.git@v0.5.2
RUN pip install git+https://github.com/NVlabs/tiny-cuda-nn.git#subdirectory=bindings/torch
RUN cd /tmp && git clone --recursive https://github.com/ashawkey/diff-gaussian-rasterization && cd diff-gaussian-rasterization && pip install .

COPY requirements-threestudio.txt /tmp
RUN cd /tmp && sudo chown 1000:1000 requirements-threestudio.txt && pip install -r requirements-threestudio.txt
WORKDIR /home/${USER_NAME}/threestudio
