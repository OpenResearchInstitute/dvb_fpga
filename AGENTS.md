# CLAUDE.md

This file provides guidance to AI agents when working with code in this repository.

## Project Overview

This is a DVB-S2 (Digital Video Broadcasting - Satellite Second Generation) RTL encoder
implementation in VHDL-2008, targeting Xilinx FPGAs. It implements the full DVB-S2 transmission
chain per ETSI EN 302 307-1, from baseband input to complex IQ output.

## Key Directories

- `rtl/` — Core RTL components (VHDL)
  - `rtl/ldpc/` — LDPC encoder core, packages, and input sync
  - `dvbs2_encoder.vhd` — Top-level DVB-S2 TX encoder (chains all components)
  - `dvb_utils_pkg.vhd` — Shared types (frame_type_t, constellation_t, code_rate_t)
  - `plframe_header_pkg.vhd` — Physical layer header framing constants and functions
  - `dvbs2_encoder_regs_pkg.vhd` — Register map interface types (generated from airhdl)
- `testbench/` — VUnit testbenches for each component
- `third_party/` — Git submodules: `airhdl` (register map generator), `bch_generated` (BCH encoder
  cores), `fpga_cores` ( reusable AXI primitives), `hdl_string_format`
- `build/vivado/` — Vivado synthesis flow (build.tcl, add_dvbs2_files.tcl)
- `build/yosys/` — Yosys synthesis script
- `boards/` — Board-specific Vivado projects (zc706, zcu106, LiteFury)
- `gnuradio_data/` — GNU Radio flow graphs for generating test reference data
- `misc/ldpc/` — LDPC parity-check matrix CSV files from DVB-S2 spec

## Architecture

The DVB-S2 encoder pipeline (data flows left to right via AXI-Stream):

1. **Width converter** (fpga_cores) — converts configurable input width to 8-bit
2. **axi_bbframe_length_enforcer** — resizes BBFRAMEs to expected length
3. **axi_baseband_scrambler** — baseband scrambling
4. **axi_bch_encoder** — BCH outer encoding
5. **axi_ldpc_encoder** — LDPC inner encoding
6. **axi_bit_interleaver** — bit interleaving (bypassed for QPSK)
7. **axi_constellation_mapper** — constellation mapping (QPSK/8PSK/16APSK/32APSK)
8. **axi_physical_layer_framer** — physical layer framing (header + scrambler)

A register map (AXI-Lite) provides configuration, control, and debug status for each pipeline stage.
The register map is generated from `third_party/airhdl/dvbs2_encoder_regs.json`.

All components use AXI-Stream interfaces with `tID` carrying encoded frame configuration (frame
type, constellation, code rate, pilots flag), enabling per-frame reconfiguration without reset.

## Commands

### Running Tests (Docker — recommended, matches CI)

```bash
./misc/run_tests.sh
./misc/run_tests.sh -l                          # list tests
./misc/run_tests.sh --individual-config-runs    # individual test per config (slower)
```

### Running Tests (local)

```bash
pip install vunit-hdl
./run.py                                          # run all tests
./run.py -l                                       # list tests
./run.py --simulator nvc                          # use NVC simulator
./run.py --simulator ghdl                         # use GHDL simulator
./run.py --simulator modelsim                     # use ModelSim
```

Tests first generate reference data via GNU Radio (first run only), then run VHDL simulation against
that data.

### Synthesis

**Yosys (open source):**

```bash
./misc/run_synth.sh
```

**Vivado:**

```bash
vivado -source ./build/vivado/build.tcl
```

**Board-specific builds:**

```bash
# ZCU106
vivado -source ./boards/zcu106/build.tcl
# ZC706
vivado -source ./boards/zc706/build.tcl
```

### Linting

```bash
# .hdl_checker.config defines source paths and VHDL-2008 flag
# Run hdl_checker if installed: hdl-checker
```

## Test Framework

- Uses **VUnit** for VHDL test orchestration
- Tests generate reference data via GNU Radio flow graphs
  (`gnuradio_data/dvbs2_encoder_flow_diagram.py`)
- Each test config is a combination of: frame type (normal/short), constellation
  (QPSK/8PSK/16APSK/32APSK), code rate (1/4 through 9/10), and pilots (on/off)
- Test data lives in `gnuradio_data/<FRAME_TYPE>_<CONSTELLATION>_<CODE_RATE>/`
- LDPC tables and modulation RAM contents are generated on first run by `run.py`

## Submodules

Initialize submodules before working:

```bash
git submodule update --init --recursive
```

## Debugging

- `wave.do` — ModelSim/Vivado waveform dump configuration
- Each pipeline stage has an `axi_stream_debug` wrapper (from fpga_cores) exposing frame count, word
  count, min/max frame length, and AXI handshake strobes via the register map
- The `dvbs2_encoder.vhd` has debug signals (`dbg_frame_type`, `dbg_constellation`, `dbg_code_rate`)
  marked for debugging
- Set `config_force_output_ready` to disconnect output for debugging pipeline stalls
