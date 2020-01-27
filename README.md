# DVB FPGA ![CI](https://github.com/phase4ground/dvb_fpga/workflows/CI/badge.svg)

This project aims to implement RTL components for DVB-S2, initially focusing on
the transmission side.

## Functional guidelines

* Behaviour should match exactly what GNU Radio produces for every combination of
  parameters described on the DVB-S2 base spec (no extensions yet). This means
  components should handle
  * Frame types: Normal and short
  * Constellations: 8 PSK, 16 APSK and 32 APSK
  * Code rates: 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, 9/10,
* Components should also handle parameters changing on every frame, that is, they
  should handle frame with config A then a frame with config B immediately
  afterwards without requiring reset or wait cycles
* Use AXI-Stream interfaces

## Components' status

### Core DVB-S2 components

| Component name      | Status              | Notes                                            |
| :---                | :---:               | :---                                             |
| AXI BCH encoder     | Simulation complete | Different data widths can be generated           |
| AXI bit interleaver | Simulation complete | No generic data width (fixed to 8 at the moment) |

### Simulation helpers

| Component name   | Status              | Notes               |
| :---             | :---:               | :---                |
| AXI file reader  | Simulation complete | [Issue #1][issue_1] |
| AXI file compare | Simulation complete |                     |

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
[issue_1]: https://github.com/phase4ground/dvb_fpga/issues/1
