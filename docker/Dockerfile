#
# DVP IP
#
# Copyright 2019 by Suoto <andre820@gmail.com>
#
# This file is part of DVP IP.
#
# DVP IP is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DVP IP is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DVP IP.  If not, see <http://www.gnu.org/licenses/>.

FROM ubuntu:19.04

ENV BUILDERS /builders

ENV DEBIAN_FRONTEND noninteractive
RUN dpkg --add-architecture i386

ENV PACKAGES="ca-certificates       \
              cmake                 \
              g++                   \
              g++-multilib          \
              gcc                   \
              gcc-multilib          \
              git                   \
              gnat                  \
              lib32gcc1             \
              lib32stdc++6          \
              lib32z1               \
              libtcl8.6             \
              libx11-6:i386         \
              libxext6:i386         \
              libxft2:i386          \
              make                  \
              python3-pip           \
              python3-setuptools    \
              wget                  \
              zlib1g-dev            \
              gnuradio              \
              libboost-all-dev      \
              libgmp-dev            \
              swig                  \
              python3-numpy         \
              python3-mako          \
              python3-sphinx        \
              python3-lxml          \
              doxygen               \
              libfftw3-dev          \
              libcomedi-dev         \
              libsdl1.2-dev         \
              libgsl-dev            \
              libqwt-qt5-dev        \
              libqt5opengl5-dev     \
              python3-pyqt5         \
              liblog4cpp5-dev       \
              libzmq3-dev           \
              python3-yaml          \
              python3-click         \
              python3-click-plugins \
              python3-zmq"

RUN apt-get update -qq                                    && \
    apt-get install -qq --no-install-recommends $PACKAGES && \
    apt-get clean                                         && \
    apt-get autoclean                                     && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install wheel vunit-hdl

# #####################################################################################
# ## Setup GNU Radio ##################################################################
# #####################################################################################
# RUN git clone --branch=v3.8.0.0 --depth 1 --recurse-submodules https://github.com/gnuradio/gnuradio

# WORKDIR /gnuradio/build

# RUN cmake -DCMAKE_BUILD_TYPE=Release                                \
#           -DPYTHON_EXECUTABLE="$(command -v /usr/bin/python3.7)"    \
#           ../                                                    && \
#     make -j8                                                     && \
#     make install &&                                                 \
#     ldconfig

# RUN rm -rf /gnuradio

#####################################################################################
## Setup GHDL #######################################################################
#####################################################################################
WORKDIR $BUILDERS

# Build GHDL from source
WORKDIR /tmp/
RUN git clone --depth=1 --branch=v0.36 https://github.com/ghdl/ghdl
WORKDIR /tmp/ghdl
WORKDIR /tmp/ghdl/build

RUN ../configure --prefix=$BUILDERS/ghdl && \
    make -j                              && \
    make install

RUN rm -rf /tmp/ghdl

#####################################################################################
## Setup ModelSim ###################################################################
#####################################################################################
COPY msim $BUILDERS/msim

# Test installations
RUN $BUILDERS/ghdl/bin/ghdl --version
RUN /builders/msim/modelsim_ase/linuxaloem/vsim -version
