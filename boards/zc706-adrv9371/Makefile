#
# DVB FPGA
#
# Copyright 2019 by suoto <andre820@gmail.com>
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

.PHONY: patch
.DEFAULT: all

HDL_DIR = $(PWD)/hdl-2019_r2
HDL_RELEASE_URL = https://github.com/analogdevicesinc/hdl/archive/refs/tags/2019_r2.tar.gz
HDL_TARBALL = $(PWD)/$(notdir $(HDL_RELEASE_URL))
SYSTEM_PROJECT = $(HDL_DIR)/projects/adrv9371x/zc706/system_project.tcl

$(HDL_DIR):
	wget $(HDL_RELEASE_URL) -O $(HDL_TARBALL)
	tar zxvf $(HDL_TARBALL)

patch: $(HDL_DIR)
	# Change AD's Tcl file to add the DVB encoder before actually building the
	# project
	@if ! grep -q insert_encoder $(SYSTEM_PROJECT); then                                          \
		echo 'Patching $(SYSTEM_PROJECT)'                                                        && \
		sed -e 's,adi_project_run .*,source $(PWD)/insert_encoder.tcl\n&,g' -i $(SYSTEM_PROJECT)  ; \
	fi

all: $(HDL_DIR) patch
	cd $(dir $(SYSTEM_PROJECT)) && make all

clean:
	rm -rf $(HDL_DIR)
