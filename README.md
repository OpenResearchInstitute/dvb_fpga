# DVB FPGA

Early work, but the idea is:

* Implement RTL components for DVB-S2
* Provide helpers for development (like reading/writing/checking files generated
  by GNU Radio)

## Running tests

```sh
# Install VUnit
pip install vunit-hdl
# Clone this repo and submodules
git clone --recurse-submodules  https://github.com/phase4ground/dvb_fpga
# Run the tests
cd dvb_fpga
./run.py
```

### Requirements

* A mixed language simulator
* [VUnit][vunit]

**Note:** While VUnit supports many tools and switching should be
straightforward, code in this repo has been tested mostly with
[ModelSim][ModelSim].

## TODO

* Run tests on Travis or Github actions
* Translate needed Verilog files inside [third_party/][third_party] to VHDL to
  allow single language simulators to be used
  * Currently the only file is the
    [third_party/wb2axip/rtl/skidbuffer.v][axi_skid_buffer]
* Use open source simulators

[vunit]: https://vunit.github.io/
[ModelSim]: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html
[third_party]: https://github.com/phase4ground/dvb_fpga/tree/master/third_party
[axi_skid_buffer]: https://github.com/ZipCPU/wb2axip/blob/74b27bf0e214c7c28a8cba4ecd17c8cb744b4f02/rtl/skidbuffer.v
