# DVB FPGA

Early work, but the idea is:

* Implement RTL components for DVB-S2
* Provide helpers for development (like reading/writing/checking files generated
  by GNU Radio)

## Running tests

Tests can be run locally or on a Docker container. Running locally will require
GNU Radio, VUnit and a VHDL simulator.

### Using Docker

Uses the same container used for CI

```sh
# Clone this repo and submodules
git clone --recurse-submodules  https://github.com/phase4ground/dvb_fpga
cd dvb_fpga
# Run the tests
./docker/run_tests.sh
```

Arguments passed to `docker/run_tests.sh` will be passed to `run.py` and, by
extension, to VUnit (no environment variable is passed on though).

### Running locally

* Requirements
  * GNU Radio
  * A VHDL simulator
  * [VUnit][vunit]

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

[vunit]: https://vunit.github.io/
