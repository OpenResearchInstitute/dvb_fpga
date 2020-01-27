#!/usr/bin/env bash
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

set -e

PATH_TO_REPO=$(git rev-parse --show-toplevel)

VUNIT_ARGS="$*"

CONTAINER="suoto/dvb_fpga_ci:fix_bit_interleaver"

# Need to add some variables so that uploading coverage from witihin the
# container to codecov works
docker run                                                        \
  --rm                                                            \
  --mount type=bind,source="$PATH_TO_REPO",target=/project \
  --net=host                                                      \
  --env="DISPLAY"                                                 \
  --volume="$HOME/.Xauthority:/root/.Xauthority:rw"               \
  --env USER_ID="$(id -u)"                                        \
  --env GROUP_ID="$(id -g)"                                       \
  --env VUNIT_ARGS="$VUNIT_ARGS"                                  \
  --env USERNAME="$USER"                                          \
  $CONTAINER /project/docker/docker_entry_point.sh

