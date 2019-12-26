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

* A VHDL simulator
* [VUnit][vunit]

**Note:** While VUnit supports many tools and switching should be
straightforward, code in this repo has been tested mostly with
[ModelSim][ModelSim].

## TODO

* Run tests on Travis or Github actions
* Use open source simulators

[vunit]: https://vunit.github.io/
[ModelSim]: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/model-sim.html
