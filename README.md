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
cd dvb_fpga
# Generate test data
cd gnuradio_data/
make all
cd ..
# Run the tests
./run.py
```

### Requirements

* GNU Radio
* A mixed language simulator
* [VUnit][vunit]

**Note:** While VUnit supports many tools and switching should be
straightforward, code in this repo has been tested mostly with
[ModelSim][ModelSim].

[vunit]: https://vunit.github.io/
[ModelSim]: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html
[third_party]: https://github.com/phase4ground/dvb_fpga/tree/master/third_party
[axi_skid_buffer]: https://github.com/ZipCPU/wb2axip/blob/74b27bf0e214c7c28a8cba4ecd17c8cb744b4f02/rtl/skidbuffer.v
