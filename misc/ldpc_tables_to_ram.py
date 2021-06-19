#!/usr/bin/env python3
#
# DVB IP
#
# Copyright 2019 by Andre Souto (suoto)
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
# the DVB Encoder or other products you make using this source."""
Simple script to generate a VHDL package with the LDPC tables. Used tables from
https://github.com/aicodix/tables
"""

import logging
import math
import os.path as p
import re
import sys
from glob import glob
from os import makedirs

from tabulate import tabulate

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
_logger = logging.getLogger(__name__)

ROOT = p.abspath(p.dirname(__file__))

HEADER = """\
--
-- DVB IP
--
-- Copyright 2019 by Andre Souto (suoto)
--
-- This source describes Open Hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this source and make products using it under
-- the terms of the CERN-OHL-W v2 (https://ohwr.org/cern_ohl_w_v2.txt).
--
-- This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING
-- OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN-OHL-W v2 for applicable conditions.
--
-- Source location: https://github.com/phase4ground/dvb_fpga
--
-- As per CERN-OHL-W v2 section 4.1, should You produce hardware based on this
-- source, You must maintain the Source Location visible on the external case of
-- the DVB Encoder or other products you make using this source.
"""

_PARAM_RE = re.compile(r"ldpc_table_(FECFRAME_(?:NORMAL|SHORT))_(C\d_\d+).csv")


class LdpcTable:
    """
    Helper class to handle extracting data from a CSV file with LDPC coefficients
    """

    def __init__(self, path):
        self._path = path
        self._table = tuple(self._read())

        self._widths = self._getColumnWidths()

        # Extract the frame type and code rate of this table from the path
        match = _PARAM_RE.search(self._path)

        self.frame_type = match.group(1).lower()
        self.code_rate = match.group(2)
        _logger.debug(
            "Config of path '%s is %s, %s",
            repr(self._path),
            repr(self.frame_type),
            repr(self.code_rate),
        )

    @property
    def table(self):
        return tuple(self._table)

    def _read(self):
        _logger.info("Reading %s", self._path)
        for line in (x.strip() for x in open(self._path).readlines()):
            if not line:
                continue
            yield tuple(int(x) for x in line.split(","))

    def _getColumnWidths(self):
        max_values = {}

        for line in self._table:
            max_values[0] = max(len(line), max_values.get(0, 0))
            for cnum, col in enumerate(line):
                max_values[cnum + 1] = max(col, max_values.get(cnum + 1, 0))

        widths = {}
        for col, value in max_values.items():
            widths[col] = math.ceil(math.log2(value))

        return widths

    def _renderRamLine(self, line):
        items = [f"0 => {len(line)}"]
        for i in range(1, len(self._widths)):
            try:
                item = line[i - 1]
            except IndexError:
                #  item = f"({self._widths[i] - 1} downto 0 => 'U')"
                item = -1
            items.append(f"{i} => {item}")

        return ", ".join([str(x) for x in items])

    @property
    def name(self):
        return p.basename(self._path).split(".")[0]

    def _getWidthArray(self):
        return (
            f"constant {self.name.upper()}_COLUMN_WIDTHS : integer_vector_t := ("
            + ", ".join(
                ["%d => %d" % (key, value) for key, value in self._widths.items()]
            )
            + ");"
        )

    def getStats(self):
        width = sum(self._widths.values())
        total = self.length * width

        return dict(
            depth=self.length,
            width=width,
            entries=len(self._widths),
            total=(total + 7) // 8,
            brams_18k=max((width + 17) // 18, self.length * width / 1024 / 18),
            brams_36k=max((width + 35) // 36, self.length * width / 1024 / 36),
        )

    @property
    def length(self):
        return len(self._table)

    @property
    def widths(self):
        return tuple(self._widths.values())

    def render(self):
        _logger.debug("widths=%s", self._widths)

        width = sum(self._widths.values())

        brams_18k = max((width + 17) // 18, self.length * width / 1024 / 18)
        brams_36k = max((width + 35) // 36, self.length * width / 1024 / 36)

        columns = len(self._widths)

        lines = [
            f"  -- From {p.relpath(self._path, ROOT)}, table is {self.length}x{width} ({self.length*width/8.} bytes)",
            f"  -- Resource estimation: {brams_18k} x 18 kB BRAMs or {brams_36k} x 36 kB BRAMs",
            f"  {self._getWidthArray()}",
            f"",
            f"  constant {self.name.upper()} : integer_array_t"
            f"(0 to {self.length - 1})(0 to {columns - 1}) := (",
        ]

        for i, line in enumerate(self._table):

            this_line = f"    {i} => integer_vector_t'({self._renderRamLine(line)})"
            if i < self.length - 1:
                lines.append(f"{this_line},")
            else:
                lines.append(f"{this_line}")

        lines.append("  );")

        _logger.info(
            "RAM has %.2f kb (%d x %d), or %d BRAMs",
            self.length * width / 1024.0,
            self.length,
            width,
            brams_18k,
        )

        return "\n".join(lines)


def _generateRowCountRom(tables):
    """
    Generates the contents of the counter config part of the LDPC metadata table
    """
    for table in tables:
        count_cfg = []

        row_length_prev = None
        cnt = 0

        for row_length in (len(row) for row in table.table):
            if row_length_prev is not None and row_length != row_length_prev:
                count_cfg += [(cnt, row_length_prev)]
                cnt = 0

            cnt += 1
            row_length_prev = row_length

        if row_length_prev is not None:
            count_cfg += [(cnt, row_length_prev)]

        # Two stages is enough to handle all tables, we'll force to that even
        # if 1 stage would suffice to make the HDL side easier
        if len(count_cfg) != 2:
            cnt, row_length = count_cfg[0]
            count_cfg = [(cnt // 2, row_length), (cnt - cnt // 2, row_length)]

        yield (table.frame_type, table.code_rate), count_cfg


LDPC_Q = {
    ("fecframe_normal", "C1_4"): 135,
    ("fecframe_normal", "C1_3"): 120,
    ("fecframe_normal", "C2_5"): 108,
    ("fecframe_normal", "C1_2"): 90,
    ("fecframe_normal", "C3_5"): 72,
    ("fecframe_normal", "C2_3"): 60,
    ("fecframe_normal", "C3_4"): 45,
    ("fecframe_normal", "C4_5"): 36,
    ("fecframe_normal", "C5_6"): 30,
    ("fecframe_normal", "C8_9"): 20,
    ("fecframe_normal", "C9_10"): 18,
    ("fecframe_short", "C1_4"): 36,
    ("fecframe_short", "C1_3"): 30,
    ("fecframe_short", "C2_5"): 27,
    ("fecframe_short", "C1_2"): 25,
    ("fecframe_short", "C3_5"): 18,
    ("fecframe_short", "C2_3"): 15,
    ("fecframe_short", "C3_4"): 12,
    ("fecframe_short", "C4_5"): 10,
    ("fecframe_short", "C5_6"): 8,
    ("fecframe_short", "C8_9"): 5,
}


def _generateTablesRom(tables):
    count_cfg = dict(_generateRowCountRom(tables))

    package = [
        f"  -- Record with LDPC metadata",
        f"  type ldpc_metadata_t is record",
        f"    addr : integer;",
        f"    q : integer;",
        f"    stage_0_loops: integer;",
        f"    stage_0_rows: integer;",
        f"    stage_1_loops: integer;",
        f"    stage_1_rows: integer;",
        f"  end record ldpc_metadata_t;",
        f"",
        f"  -- Reduce the footprint of this",
        f"  constant LDPC_TABLE_DATA_WIDTH : integer := numbits(max(DVB_N_LDPC));",
        f"",
        f"  -- Use this function to get the starting address of a given config within the LDPC_DATA_TABLE",
        f"  function get_ldpc_metadata (",
        f"    constant frame_type : frame_type_t;",
        f"    constant code_rate : code_rate_t) return ldpc_metadata_t;",
        "",
    ]

    #  data_width = max(y for table in tables for y in table.widths)
    data_width = "LDPC_TABLE_DATA_WIDTH"
    table_length = sum(len(y) for table in tables for y in table.table)
    address_width = math.ceil(math.log2(table_length))

    package_body = [
        #  Generate the function that will receive the frame type and code rate
        #  and return the address of the table
        f"  -- Use this function to get the starting address of a given config within the LDPC_DATA_TABLE",
        f"  function get_ldpc_metadata (",
        f"    constant frame_type : frame_type_t;",
        f"    constant code_rate : code_rate_t) return ldpc_metadata_t is",
        "  begin",
    ]

    _logger.debug("Address map:")
    addr = 0
    for table in tables:
        _logger.debug("0x%.4x | %4d | %s", addr, addr, table.name)
        key = (table.frame_type, table.code_rate)
        result_tuple = [
            addr,
            count_cfg[key][0][0],
            count_cfg[key][0][1],
            count_cfg[key][1][0],
            count_cfg[key][1][1],
        ]
        print(result_tuple)
        package_body += [
            f"    if frame_type = {table.frame_type} and code_rate = {table.code_rate} then",
            f"      return (",
            f"        addr => {addr},",
            f"        q => {LDPC_Q[key]},",
            f"        stage_0_loops => {count_cfg[key][0][0]},",
            f"        stage_0_rows => {count_cfg[key][0][1]},",
            f"        stage_1_loops => {count_cfg[key][1][0]},",
            f"        stage_1_rows => {count_cfg[key][1][1]});",
            f"     end if;",
        ]

        addr += sum(len(x) for x in table.table)

    package_body += [
        "",
        "    -- Return a non existing index for any config not listed above",
        "    return (addr => -1, q => -1, stage_0_loops => -1, stage_0_rows => -1, stage_1_loops => -1, stage_1_rows => -1);",
        "  end function get_ldpc_metadata;",
        "",
    ]

    _logger.debug(
        "Base widths are %s for data and %d for address", data_width, address_width
    )

    # Now generate the actual table
    package += [
        "",
        f"  constant LDPC_DATA_TABLE : std_logic_array_t"
        f"(0 to {table_length - 1})"
        f"({data_width} - 1 downto 0) := (",
    ]

    addr = 0

    rom_content = []
    for table in tables:
        rom_content += [
            f"    -- Table for {table.frame_type}, {table.code_rate}",
        ]

        for row in table.table:
            for i, column in enumerate(row):
                # Append the is_last flag and the actual data
                is_last = i == len(row) - 1

                #  vhdl_bin_value = bin(column)[2:]
                #  vhdl_bin_value = '0'*(data_width - len(vhdl_bin_value)) + vhdl_bin_value

                entry = (
                    f"    {addr:4d} => "
                    f"std_logic_vector(to_unsigned({column:5d}, {data_width}))"
                )

                if addr < table_length - 1:
                    entry += ", -- %5d / 0x%.4x" % (column, column)
                    if is_last:
                        entry += " -- last item of row"

                rom_content += [entry]

                addr += 1

    package += ["\n".join(rom_content) + ");"]

    return "\n".join(package), "\n".join(package_body)


def main():
    lines = str(HEADER)

    lines += "\n".join(
        [
            "library ieee;",
            "use ieee.std_logic_1164.all;",
            "use ieee.numeric_std.all;",
            "",
            "library fpga_cores;",
            "use fpga_cores.common_pkg.all;",
            "",
            "use work.dvb_utils_pkg.all;",
            "",
        ]
    )

    paths = sorted(glob(p.join(ROOT, "ldpc", "*.csv")))

    rendered_tables = ""

    stats = []

    ldpc_tables = tuple(LdpcTable(x) for x in paths)

    for ldpc_table in ldpc_tables:
        stats += [["--", ldpc_table.name] + list(ldpc_table.getStats().values())]
        rendered_tables += ldpc_table.render()
        rendered_tables += "\n\n"

    lines += "\n-- Summary of statistics\n\n"
    lines += tabulate(
        stats,
        headers=(
            "--",
            "table",
            "depth",
            "width (bits)",
            "width (entries)",
            "total (bytes)",
            "18k BRAMs",
            "36k BRAMs",
        ),
    )
    lines += "\n".join(["", "", "package ldpc_tables_pkg is", "", "",])

    lines += "\n".join(
        [
            "",
            "  -- LDPC_TABLE_FECFRAME_<frame_type>_<code_rate>_COLUMN_WIDTHS constants have the bit",
            "  -- width of each row",
            "",
            "  -- LDPC_TABLE_FECFRAME_<frame_type>_<code_rate> is the actual LDPC where the number of",
            "  -- columns is normalized to the row with most columns and the first column of each row",
            "  -- contains the number of valid elements within the row. Elements outisde the valid range",
            "  -- are represented as -1",
            "",
            "",
            "",
        ]
    )
    lines += rendered_tables

    package, package_body = _generateTablesRom(ldpc_tables)

    lines += "\n".join(
        [
            "",
            package,
            "",
            "end package ldpc_tables_pkg;",
            "",
            "package body ldpc_tables_pkg is",
            package_body,
            "end package body ldpc_tables_pkg;",
        ]
    )

    target_file = p.abspath(p.join(ROOT, "..", "rtl", "ldpc", "ldpc_tables_pkg.vhd"))
    if not p.exists(p.dirname(target_file)):
        makedirs(p.dirname(target_file))
    open(target_file, "w").write(lines)


main()
