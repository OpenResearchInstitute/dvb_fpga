#
# DVB FPGA
#
# Copyright 2019 by Suoto <andre820@gmail.com>
#
# This file is part of DVB FPGA.
#
# DVB FPGA is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DVB FPGA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.

FROM ghdl/vunit:llvm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq                                                && \
    apt-get install -y --no-install-recommends gnuradio=3.7.13.4-4+b1 && \
    apt-get clean                                                     && \
    apt-get autoclean                                                 && \
    rm -rf /var/lib/apt/lists/*
