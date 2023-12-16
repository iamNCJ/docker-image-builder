FROM nvidia/cudagl:11.3.1-devel-ubuntu20.04

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
	libreadline-gplv2-dev \
	libxrender1 \
	libxi6 \
	libxkbcommon-x11-0 \
	liblzma-dev \
	&& apt-get autoremove -y \
	&& apt-get clean -y

RUN echo "Installing Python ver. ${PYTHON_VERSION}..." \
	&& cd /opt \
	&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
	&& tar xzf Python-${PYTHON_VERSION}.tgz \
	&& cd ./Python-${PYTHON_VERSION} \
	&& ./configure --enable-optimizations \
	&& make \
	&& checkinstall

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6 8.9 9.0+PTX"
RUN echo "Installing pip packages..." \
	&& python3 -m pip install -U pip \
    && pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113 \
	&& pip3 --no-cache-dir install bpy==${BLENDER_VERSION} imageio numpy opencv-contrib-python tqdm simple-parsing blenderproc transformers \
    && pip install ninja \
    && pip install -v -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers \
    && imageio_download_bin freeimage \
    && blenderproc quickstart

# For AML
RUN ln -s /usr/local/bin/python3 /usr/bin/python
