FROM ubuntu:focal-20230605

LABEL authors="CBICA_UPenn <software@cbica.upenn.edu>"

# cmake installation
# RUN wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.tar.gz; \
#     tar -xf cmake-3.12.4-Linux-x86_64.tar.gz; \

# ENV HOME=/opt/app-root/src \
#     PATH=/opt/app-root/src/bin:/opt/app-root/bin:/opt/rh/devtoolset-4/root/usr/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt update -y

RUN echo "deb http://archive.ubuntu.com/ubuntu xenial main" | sudo tee /etc/apt/sources.list.d/xenial.list \
    apt-get update \
    update-alternatives --remove-all gcc \
    update-alternatives --remove-all g++ \
    apt-get install gcc-5 g++-5 \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10 \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 10

#general dependencies
# RUN yum install -y \
#     sudo \
#     #devtoolset-4 \
#     #devtoolset-4-gcc* \
#     # gcc \
#     # gcc-c++ \
#     make \
#     yum-utils \
#     wget \
#     git-core \
#     lapack \
#     lapack-devel \
#     unzip \
#     tcl \
#     tcl-devel \
#     tk \
#     tk-devel \
#     fftw \
#     fftw-devel \
#     mpich \
#     mpich-devel \
#     mesa-libGL \
#     mesa-libGL-devel \
#     xorg-x11-server-Xorg \
#     xorg-x11-xauth \
#     xorg-x11-apps \
#     libXt-devel \
#     tcl \
#     time \
#     libmpc-devel \
#     mpfr-devel \
#     gmp-devel \
#     dos2unix \
#     fuse-sshfs \
#     doxygen
RUN apt-get install -y \
    build-essential \
    libssl-dev \
    make \
    wget \
    git \
    liblapack-dev \
    unzip \
    tcl \
    tcl-dev \
    tk \
    tk-dev \
    libgl1-mesa-dev \
    libxt-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    dos2unix \
    fuse-sshfs \
    doxygen 




# installing CMake
RUN rm -rf /usr/bin/cmake; \
    wget https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.sh; \
    mkdir /opt/cmake; \
    sh cmake-3.12.4-Linux-x86_64.sh --prefix=/opt/cmake --skip-license; \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake; \
    rm -rf https://cmake.org/files/v3.12/cmake-3.12.4-Linux-x86_64.sh

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
    cmake -DCMAKE_INSTALL_PREFIX=./install_libs -DQT_DOWNLOAD_FORCE=OFF -Wno-dev .. && make -j2 && rm -rf qt.zip

ARG CMAKE_PREFIX_PATH=`pwd`/CaPTk/bin/ITK-build:`pwd`/CaPTk/bin/DCMTK-build
ENV CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH
ARG DCMTK_DIR=`pwd`/CaPTk/bin/DCMTK-build
ENV DCMTK_DIR=$DCMTK_DIR

## trying to install using https://gist.github.com/craigminihan/b23c06afd9073ec32e0c
#RUN curl ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-4.9.2/gcc-4.9.2.tar.bz2 -O ;\
#    tar xvfj gcc-4.9.2.tar.bz2; \
#    cd gcc-4.9.2; \
#    ./configure --disable-multilib --enable-languages=c,c++; \
#    make -j2; \
#    make install

# LFS install
# RUN yum install -y epel-release git; \
#     curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash; \
#     yum install -y git-lfs; \
#     git lfs install
    # echo 'export GIT_LFS_SKIP_SMUDGE=1' >> ~/.bashrc

# ENV GIT_LFS_SKIP_SMUDGE=1

# RUN time git clone https://github.com/CBICA/CaPTk.git --depth 1;\
#     cd CaPTk; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"; \
#     time git lfs pull --include "binaries/precompiledApps/linux.zip"
    
# download relevant files
# RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/precompiledApps/linux.zip -O binaries_linux.zip

# RUN time wget https://github.com/CBICA/CaPTk/raw/master/binaries/qt_5.12.1/linux.zip -O qt.zip

# ensuring azure requirements are met: : https://docs.microsoft.com/en-us/azure/devops/pipelines/process/container-phases?view=azure-devops&tabs=yaml#linux-based-containers
# # apparently, this messes up azure
# ENTRYPOINT [ "/bin/bash" ]

# # nodejs is needed for azure
# RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash; \
#     #curl -sL https://rpm.nodesource.com/setup_12.x | sudo -E bash -; \
#     curl -sL https://rpm.nodesource.com/setup | bash -; \
#     yum install -y nodejs
#     #curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash; \
#     #nvm install -y node; \

# ENV NVM_DIR="$HOME/.nvm"

# # tests
# RUN cmake --version; \
#     gcc --version; \
#     g++ --version; \
#     node -v; \
#     npm -v