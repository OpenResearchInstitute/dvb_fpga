#
# DVB FPGA
#
# Copyright 2019-2022 by suoto <andre820@gmail.com>
#
# This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
#
# You may redistribute and modify this source and make products using it under
# the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
#
# This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
# OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
# Please see the CERN-OHL-W v2 for applicable conditions.
#
# Source location: https://github.com/phase4ground/dvb_fpga
#
# As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
# source, You must maintain the Source Location visible on the external case of
# the DVB Encoder or other products you make using this source.
FROM ghdl/vunit:llvm

RUN apt-get update -qq                                    && \
    apt-get install -y --no-install-recommends gnuradio=3.8.2.0-14 && \
    apt-get clean                                                  && \
    apt-get autoclean                                              && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /project
