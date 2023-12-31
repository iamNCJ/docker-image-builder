FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV PYTHON_VERSION=3.10.13
ENV BLENDER_VERSION=4.0.0

RUN echo "Installing apt packages..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y update --no-install-recommends \
    && apt-get upgrade -y \
    && apt-get -y install --no-install-recommends \
    git \
    wget \
    ffmpeg \
    tk-dev \
    libxi-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    libomp-dev \
    libssl-dev \
    zlib1g-dev \
    libcgal-dev \
    libgdbm-dev \
    libglew-dev \
    python3-dev \
    python3-pip \
    qtbase5-dev \
    checkinstall \
    libglfw3-dev \
    libeigen3-dev \
    libgflags-dev \
    libxrandr-dev \
    libopenexr-dev \
    libsqlite3-dev \
    libxcursor-dev \
    build-essential \
    libcgal-qt5-dev \
    libxinerama-dev \
    libboost-all-dev \
    libfreeimage-dev \
    libncursesw5-dev \
    libatlas-base-dev \
    libqt5opengl5-dev \
    libgoogle-glog-dev \
    libsuitesparse-dev \
    python3-setuptools \
    libreadline-dev \
    libxrender1 \
    libxi6 \
    libxkbcommon-x11-0 \
    liblzma-dev \
    pkg-config \
    libglvnd-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    python3 \
    python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Installing pip packages..." \
    && python3 -m pip install -U pip setuptools \
    && pip3 install torch torchvision xformers --index-url https://download.pytorch.org/whl/cu118 \
    && pip3 --no-cache-dir install bpy==${BLENDER_VERSION} imageio numpy opencv-contrib-python tqdm simple-parsing blenderproc transformers \
    && imageio_download_bin freeimage \
    && blenderproc quickstart

# For AML
RUN ln -s /usr/local/bin/python3 /usr/bin/python
