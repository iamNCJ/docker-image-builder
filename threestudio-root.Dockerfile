# Reference:
# https://github.com/cvpaperchallenge/Ascender
# https://github.com/nerfstudio-project/nerfstudio

FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

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

RUN pip install --upgrade pip setuptools ninja
RUN pip install torch torchvision xformers --index-url https://download.pytorch.org/whl/cu121
# Install nerfacc and tiny-cuda-nn before installing requirements.txt
# because these two installations are time consuming and error prone
RUN pip install git+https://github.com/KAIR-BAIR/nerfacc.git@v0.5.2
RUN pip install git+https://github.com/NVlabs/tiny-cuda-nn.git#subdirectory=bindings/torch
RUN pip install git+https://github.com/eliphatfs/cumesh2sdf.git
#COPY diso-0.0.6-cp310-cp310-linux_x86_64.whl /tmp
#RUN pip install /tmp/diso-0.0.6-cp310-cp310-linux_x86_64.whl

COPY requirements-threestudio.txt /tmp
RUN cd /tmp && pip install -r requirements-threestudio.txt
WORKDIR /root/threestudio
