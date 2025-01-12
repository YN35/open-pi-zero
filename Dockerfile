FROM nvidia/cuda:12.1.0-devel-ubuntu20.04
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV DEBIAN_FRONTEND=noninteractive

# Install packages for simpler
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion build-essential ca-certificates cmake curl git \
    htop libegl1 libxext6 libjpeg-dev libpng-dev  libvulkan1 rsync \
    tmux unzip vim vulkan-utils wget xvfb pkg-config \
    libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev libglib2.0-0
RUN rm -rf /var/lib/apt/lists/*

# python (latest version)
WORKDIR /
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py310_23.1.0-1-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

# https://github.com/haosulab/ManiSkill/issues/9
COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY docker/nvidia_layers.json /etc/vulkan/implicit_layer.d/nvidia_layers.json

# install dependencies
WORKDIR /root
RUN pip install pip==24.2 setuptools==75.2.0 wheel==0.44.0
RUN pip install torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121
RUN pip install av==12.0.0


RUN git clone https://github.com/simpler-env/ManiSkill2_real2sim.git
RUN pip install -e ./ManiSkill2_real2sim
RUN git clone https://github.com/simpler-env/SimplerEnv.git
RUN pip install -e ./SimplerEnv

# pip install -e .