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

FROM ghdl/vunit:llvm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq                                  && \
    apt-get install -y --no-install-recommends gnuradio && \
    apt-get clean                                       && \
    apt-get autoclean                                   && \
    rm -rf /var/lib/apt/lists/*
