# Use a CUDA 12.1 base image
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables for non-interactive setup and CUDA 12.1
# Added compute capabilities for Hopper (9.0) and Ada (8.9) GPUs
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    CUDA_HOME=/usr/local/cuda-12.1 \
    TORCH_CUDA_ARCH_LIST="8.6 8.9 9.0"

# Set shell to bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        make \
        wget \
        tar \
        build-essential \
        libgl1-mesa-dev \
        curl \
        unzip \
        git \
        python3-dev \
        python3-pip \
        libglib2.0-0 \
        x11-apps \
        python3-tk \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

# Configure environment paths for CUDA 12.1
RUN echo "export PATH=/usr/local/cuda/bin:$PATH" >> /etc/bash.bashrc \
    && echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH" >> /etc/bash.bashrc \
    && echo "export CUDA_HOME=/usr/local/cuda-12.1" >> /etc/bash.bashrc

# Install PyTorch, torchvision, and xformers for CUDA 12.1
RUN pip3 install \
    torch==2.1.0 \
    torchvision==0.16.0 \
    xformers \
    --index-url https://download.pytorch.org/whl/cu121

# Copy the project files
COPY . /streamdiffusion
WORKDIR /streamdiffusion

# STEP 1: Install complex NVIDIA dependencies from our requirements file
RUN pip3 install -r /streamdiffusion/requirements-tensorrt-cu12.txt

# Install StreamDiffusion with TensorRT support
RUN python setup.py develop easy_install streamdiffusion[tensorrt]

RUN 

# Set the final working directory
WORKDIR /home/ubuntu/streamdiffusion