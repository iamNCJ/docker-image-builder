FROM nvidia/cuda:12.9.1-devel-ubuntu24.04

ENV LC_ALL="C.UTF-8"
ENV LANG="C.UTF-8"
ENV PYTHON_VERSION=3.11.13
ENV BLENDER_VERSION=4.5.3
ENV PATH="/usr/local/bin:$PATH"

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
	&& ./configure --enable-optimizations --prefix=/usr/local \
	&& make \
	&& make install \
	&& cd /opt \
	&& rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz

RUN echo "Installing pip packages..." \
	&& /usr/local/bin/python3 -m pip install --upgrade pip \
    && pip3 install torch torchvision xformers --index-url https://download.pytorch.org/whl/cu129 \
	&& /usr/local/bin/python3 -m pip install --no-cache-dir bpy==${BLENDER_VERSION} imageio numpy opencv-contrib-python tqdm simple-parsing bpy-helper \
	&& /usr/local/bin/python3 -c "import imageio; imageio.plugins.freeimage.download()"

# Update python symlinks for consistency
RUN update-alternatives --install /usr/bin/python python /usr/local/bin/python3 1 \
	&& update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3 1 \
	&& update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3 1 \
	&& update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip3 1
