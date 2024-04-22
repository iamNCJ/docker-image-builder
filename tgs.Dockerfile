FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6"
ENV TCNN_CUDA_ARCHITECTURES=86;80;75;70;61;60
ENV FORCE_CUDA=1

ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:/home/${USER_NAME}/.local/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV LIBRARY_PATH=${CUDA_HOME}/lib64/stubs:${LIBRARY_PATH}

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
    python3-dev \
    python3-pip \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools ninja
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

RUN python -c "import torch; print(torch.version.cuda)"
COPY requirements-tgs.txt /tmp
RUN cd /tmp && pip install -r requirements-tgs.txt

# install pointnet2_ops from snowflake
RUN git clone https://github.com/AllenXiangX/SnowflakeNet.git && cd SnowflakeNet/models/pointnet2_ops_lib && python setup.py install

# install pytorch3d
RUN git clone -b v0.7.3 https://github.com/facebookresearch/pytorch3d.git && cd pytorch3d && python setup.py install

# install torch-scatter
RUN git clone https://github.com/rusty1s/pytorch_scatter.git && cd pytorch_scatter && git checkout 140d3ad && python setup.py install

# install diff-gaussian-rasterization
RUN git clone --recursive https://github.com/graphdeco-inria/diff-gaussian-rasterization.git && cd diff-gaussian-rasterization && python setup.py install
