#!/usr/bin/env python3
#
# DVB FPGA
#
# Copyright 2019 by Suoto <andre820@gmail.com>
#
# This file is part of DVB FPGA.
#
# DVB FPGA is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# DVB FPGA is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with DVB FPGA.  If not, see <http://www.gnu.org/licenses/>.
"""
Simple script to generate a VHDL package with the LDPC tables. Used tables from
https://github.com/aicodix/tables
"""

import logging
import math
import os.path as p
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
-- Copyright 2020 by Suoto <andre820@gmail.com>
--
-- This file is part of the DVB IP.
--
-- DVB IP is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- DVB IP is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with DVB IP.  If not, see <http://www.gnu.org/licenses/>.

"""


class Unsigned:
    def __init__(self, value, width):
        self._value = value
        self._width = width

    def render(self):
        return f"to_unsigned({self._value}, {self._width})"

    def __repr__(self):
        return self.render()


class LdpcTable:
    def __init__(self, path):
        self._path = path
        self._table = tuple(self._read())

        self._widths = self._getColumnWidths()

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
            f"constant {self.name.upper()}_COLUMN_WIDTHS : integer_vector := ("
            + ", ".join(
                ["%d => %d" % (key, value) for key, value in self._widths.items()]
            )
            + ");"
        )

    def getStats(self):
        depth = len(self._table)
        width = sum(self._widths.values())
        total = depth * width

        return dict(
            depth=depth,
            width=width,
            entries=len(self._widths),
            total=(total + 7) // 8,
            brams_18k=max((width + 17) // 18, depth * width / 1024 / 18),
            brams_36k=max((width + 35) // 36, depth * width / 1024 / 36),
        )

    def render(self):
        _logger.debug("widths=%s", self._widths)

        depth = len(self._table)
        width = sum(self._widths.values())

        brams_18k = max((width + 17) // 18, depth * width / 1024 / 18)
        brams_36k = max((width + 35) // 36, depth * width / 1024 / 36)

        columns = len(self._widths)

        lines = [
            f"  -- From {p.relpath(self._path, ROOT)}, table is {depth}x{width} ({depth*width/8.} bytes)",
            f"  -- Resource estimation: {brams_18k} x 18 kB BRAMs or {brams_36k} x 36 kB BRAMs",
            f"  {self._getWidthArray()}",
            "",
            f"  constant {self.name.upper()} : integer_2d_array_t(0 to {depth - 1})(0 to {columns - 1}) := (",
        ]

        for i, line in enumerate(self._table):

            this_line = f"    {i} => integer_vector'({self._renderRamLine(line)})"
            if i < depth - 1:
                lines.append(f"{this_line},")
            else:
                lines.append(f"{this_line}")

        lines.append("  );")

        _logger.info(
            "RAM has %.2f kb (%d x %d), or %d BRAMs",
            depth * width / 1024.0,
            depth,
            width,
            brams_18k,
        )

        return "\n".join(lines)


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
        ]
    )

    paths = sorted(glob(p.join(ROOT, "ldpc", "*.csv")))

    rendered_tables = ""

    stats = []

    for path in paths:
        ldpc_table = LdpcTable(path)
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

    lines += rendered_tables

    lines += "\n".join(["", "end package ldpc_tables_pkg;",])

    target_file = p.abspath(p.join(ROOT, "..", "rtl", "ldpc", "ldpc_tables_pkg.vhd"))
    if not p.exists(p.dirname(target_file)):
        makedirs(p.dirname(target_file))
    open(target_file, "w").write(lines)


main()
