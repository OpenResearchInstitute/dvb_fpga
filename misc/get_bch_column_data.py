#!/usr/bin/env python3

# pylint: disable=missing-docstring

import re
import struct
import sys

from tabulate import tabulate

_CONFIG = re.compile(
    r"(?P<frame_length>FECFRAME_SHORT|FECFRAME_NORMAL)_"
    r"MOD_(?P<modulation>8PSK|(:?(16|32)APSK))_"
    r"(?P<code_rate>C\d_\d+)"
)


def read(path):
    raw = open(path, "rb").read()

    value = None

    #  line = []

    for i, bit in enumerate(struct.iter_unpack("?", raw)):
        bit = bit[0]

        if value is None:
            value = 0

        value += bit << (7 - i % 8)

        if ((i + 1) % 8) == 0:
            yield value
            #  line += [value]
            value = None

    if value is not None:
        yield value


def _slicePackedBits(data, width=8):
    word = ""
    for bit in data:
        word += bit
        if len(word) == width:
            yield word
            #  yield int(word, 2)
            word = ""

    if word:
        yield word


def _tabulateDate(data, width=16):
    table = [[""] + list(range(width))]

    first = 0
    line = []
    for word in data:
        if len(word) == 8:
            line += ["0x%.2x" % int(word, 2)]
        else:
            _len = len(word)
            word = word + ("0" * (8 - _len))
            line += ["%db%.2x" % (_len, int(word, 2))]
            #  line += [f"{len(word)}b{word}"]
        if len(line) == width:
            table.append([first] + line)
            first += width
            line = []

    if line:
        table.append([first] + line)

    return tabulate(table)


def main():
    config = _CONFIG.search(sys.argv[1]).groupdict().copy()
    data = list(read(sys.argv[1]))

    if config["modulation"] == "8PSK":
        columns = 3
    elif config["modulation"] == "16APSK":
        columns = 4
    elif config["modulation"] == "32APSK":
        columns = 5
    else:
        assert False, "Don't know how to handle %s" % repr(config)

    bin_data = ""

    for word in data:
        word = bin(word)[2:]
        padded = "0" * (8 - len(word)) + word
        bin_data += padded

    column_len = len(bin_data) // columns

    column_bin_data = []

    for column in range(columns):
        start = column * column_len
        end = (column + 1) * column_len

        column_bin_data.append(bin_data[start:end])

    column_data = []

    for bin_data in column_bin_data:
        column_data.append(list(_slicePackedBits(bin_data)))

    table = []
    row = []

    for i, data in enumerate(column_data):
        row += ["Data for column %d\n%s" % (i, _tabulateDate(data)), ""]

        if len(row) == 4:
            table.append(row)
            row = []

    print(tabulate(table, tablefmt='plain'))

main()
