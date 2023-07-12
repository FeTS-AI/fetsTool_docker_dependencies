FROM ubuntu:xenial
ARG DEBIAN_FRONTEND=noninteractive

LABEL authors="FeTS_AI <admin@fets.ai>"

RUN apt-get update && apt-get update --fix-missing

#general dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    apt-utils \
    sudo \
    libssl-dev \
    make \
    gcc-5 \
    g++-5 
RUN apt-get update && apt-get install -y \
    wget \
    git \
    liblapack-dev \
    unzip \
    tcl \
    tcl-dev 
RUN apt-get update && apt-get install -y \
    tk \
    tk-dev \
    libgl1-mesa-dev \
    libxt-dev \
    libmpc-dev \
    libmpfr-dev 
RUN apt-get update && apt-get install -y \
    libgmp-dev \
    dos2unix \
    doxygen \
    libubsan0 \
    libcilkrts5 

# installing CMake
RUN rm -rf /usr/bin/cmake; \
    wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.sh; \
    mkdir /opt/cmake; \
    sh cmake-3.12.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license; \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake; \
    rm -rf cmake-3.12.4-Linux-x86_64.sh

# setting up the build environment
ARG GIT_LFS_SKIP_SMUDGE=1
ARG PKG_FAST_MODE=1
ARG PKG_COPY_QT_LIBS=1
ENV GIT_LFS_SKIP_SMUDGE=$GIT_LFS_SKIP_SMUDGE
ENV PKG_FAST_MODE=$PKG_FAST_MODE
ENV PKG_COPY_QT_LIBS=$PKG_COPY_QT_LIBS

# cloning CaPTk
RUN if [ ! -d "`pwd`/CaPTk" ] ; then git clone "https://github.com/CBICA/CaPTk.git" CaPTk; fi 
RUN cd CaPTk &&  git pull; \
    git submodule update --init && mkdir bin

RUN cd CaPTk/bin && echo "=== Starting CaPTk Superbuild ===" && \
    if [ ! -d "`pwd`/qt" ] ; then wget https://github.com/CBICA/CaPTk/raw/master/binaries/qt_5.12.1/linux.zip -O qt.zip; fi ; \
    cmake -DCMAKE_INSTALL_PREFIX=./install_libs -DQT_DOWNLOAD_FORCE=OFF -Wno-dev .. && make -j$(nproc) && rm -rf qt.zip && cd .. && mkdir Front-End

ARG CMAKE_PREFIX_PATH=`pwd`/CaPTk/bin/ITK-build:`pwd`/CaPTk/bin/DCMTK-build
ENV CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
ARG DCMTK_DIR=`pwd`/CaPTk/bin/DCMTK-build
ENV DCMTK_DIR=$DCMTK_DIR
