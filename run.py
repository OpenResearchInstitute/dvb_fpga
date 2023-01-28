#!/usr/bin/env python3
#
# DVB FPGA
#
# Copyright 2019-2022 by suoto <andre820@gmail.com>
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
# the DVB Encoder or other products you make using this source."VUnit test runner for DVB FPGA"
"""Main unit test entry point"""

# pylint: disable=unspecified-encoding
import logging
import math
import os
import os.path as p
import random
import re
import subprocess as subp
import sys
import time
from enum import Enum
from multiprocessing import Pool
from typing import List, NamedTuple

from vunit.ui import VUnit  # type: ignore
from vunit.vunit_cli import VUnitCLI  # type: ignore

_logger = logging.getLogger(__name__)

ROOT = p.abspath(p.dirname(__file__))


class ConstellationType(Enum):
    """
    Constellation types as defined in the DVB-S2 spec. Enum names should match
    the C/C++ defines, values are a nice string representation for the test
    names.
    """

    MOD_QPSK = "QPSK"
    MOD_8PSK = "8PSK"
    MOD_16APSK = "16APSK"
    MOD_32APSK = "32APSK"


class FrameType(Enum):
    """
    Frame types as defined in the DVB-S2 spec. Enum names should match
    the C/C++ defines, values are a nice string representation for the test
    names.
    """

    FECFRAME_NORMAL = "normal"
    FECFRAME_SHORT = "short"


class CodeRate(Enum):
    """
    Code rates as defined in the DVB-S2 spec. Enum names should match the C/C++
    defines, values are a nice string representation for the test names.
    """

    C1_4 = "1/4"
    C1_3 = "1/3"
    C2_5 = "2/5"
    C1_2 = "1/2"
    C3_5 = "3/5"
    C2_3 = "2/3"
    C3_4 = "3/4"
    C4_5 = "4/5"
    C5_6 = "5/6"
    C8_9 = "8/9"
    C9_10 = "9/10"


class TestDefinition(
    NamedTuple(
        "TestDefinition",
        [
            ("name", str),
            ("test_files_path", str),
            ("code_rate", CodeRate),
            ("frame_type", FrameType),
            ("constellation", ConstellationType),
            ("pilots", bool),
        ],
    )
):
    """
    Placeholder for a test config
    """

    def __init__(self, *args, **kwargs):  # pylint: disable=unused-argument
        super().__init__()
        self.timestamp = p.join(self.test_files_path, "timestamp")

    @staticmethod
    def fromConfigTuple(frame_type, constellation, code_rate, pilots):
        """
        Returns a TestDefinition object from a config tuple
        """
        test_files_path = p.join(
            ROOT,
            "gnuradio_data",
            f"{frame_type.name}_{constellation.name}_{code_rate.name}".upper(),
        )

        name = ",".join(
            [
                f"FrameType={frame_type.value}",
                f"ConstellationType={constellation.value}",
                f"CodeRate={code_rate.value}",
                f"pilots={pilots}",
            ]
        )

        return TestDefinition(
            name, test_files_path, code_rate, frame_type, constellation, pilots
        )

    def getTestConfigString(self):
        """
        Returns the value for the 'test_cfg' string of the testbench
        """
        # For some reason, double backslashes are stripped out on Windows, so
        # replace them with regular forward slashes
        test_files_path = self.test_files_path
        if sys.platform == "win32":
            test_files_path = test_files_path.replace("\\", "/")
        return ",".join(
            [
                self.constellation.name,
                self.frame_type.name,
                self.code_rate.name,
                "False",
                test_files_path,
            ]
        )


def _getConfigs(
    code_rates=CodeRate,
    frame_types=FrameType,
    constellations=ConstellationType,
    pilots=None,
):
    "Iterates over the configs enums and returns a iterator of TestDefinition"
    pilots = pilots or [False, True]
    for code_rate in code_rates:
        for frame_type in frame_types:
            for constellation in constellations:
                if (
                    frame_type is FrameType.FECFRAME_SHORT
                    and code_rate is CodeRate.C9_10
                ):
                    continue

                for pilot in pilots:
                    yield TestDefinition.fromConfigTuple(
                        code_rate=code_rate,
                        frame_type=frame_type,
                        constellation=constellation,
                        pilots=pilot,
                    )


TEST_CONFIGS = set(_getConfigs())


def _getAcmCommandByte(
    frame_type: FrameType,
    constellation: ConstellationType,
    code_rate: CodeRate,
    pilots: bool,
):
    result = 0
    if frame_type == FrameType.FECFRAME_SHORT:
        result |= 1 << 6
    if pilots:
        result |= 1 << 5

    try:
        result |= {
            (ConstellationType.MOD_QPSK, CodeRate.C1_4): 1,
            (ConstellationType.MOD_QPSK, CodeRate.C1_3): 2,
            (ConstellationType.MOD_QPSK, CodeRate.C2_5): 3,
            (ConstellationType.MOD_QPSK, CodeRate.C1_2): 4,
            (ConstellationType.MOD_QPSK, CodeRate.C3_5): 5,
            (ConstellationType.MOD_QPSK, CodeRate.C2_3): 6,
            (ConstellationType.MOD_QPSK, CodeRate.C3_4): 7,
            (ConstellationType.MOD_QPSK, CodeRate.C4_5): 8,
            (ConstellationType.MOD_QPSK, CodeRate.C5_6): 9,
            (ConstellationType.MOD_QPSK, CodeRate.C8_9): 10,
            (ConstellationType.MOD_QPSK, CodeRate.C9_10): 11,
            (ConstellationType.MOD_8PSK, CodeRate.C3_5): 12,
            (ConstellationType.MOD_8PSK, CodeRate.C2_3): 13,
            (ConstellationType.MOD_8PSK, CodeRate.C3_4): 14,
            (ConstellationType.MOD_8PSK, CodeRate.C5_6): 15,
            (ConstellationType.MOD_8PSK, CodeRate.C8_9): 16,
            (ConstellationType.MOD_8PSK, CodeRate.C9_10): 17,
            (ConstellationType.MOD_16APSK, CodeRate.C2_3): 18,
            (ConstellationType.MOD_16APSK, CodeRate.C3_4): 19,
            (ConstellationType.MOD_16APSK, CodeRate.C4_5): 20,
            (ConstellationType.MOD_16APSK, CodeRate.C5_6): 21,
            (ConstellationType.MOD_16APSK, CodeRate.C8_9): 22,
            (ConstellationType.MOD_16APSK, CodeRate.C9_10): 23,
            (ConstellationType.MOD_32APSK, CodeRate.C3_4): 24,
            (ConstellationType.MOD_32APSK, CodeRate.C4_5): 25,
            (ConstellationType.MOD_32APSK, CodeRate.C5_6): 26,
            (ConstellationType.MOD_32APSK, CodeRate.C8_9): 27,
            (ConstellationType.MOD_32APSK, CodeRate.C9_10): 28,
        }[(constellation, code_rate)]
    except KeyError:
        _logger.error(
            "Failed to get ACM command byte for %s, %s, %s, %s",
            frame_type,
            constellation,
            code_rate,
            pilots,
        )
        pass

    return result


def _runGnuRadio(config):
    """
    Runs gnuradio_data/dvbs2_encoder_flow_diagram.py script via shell. Reason
    for not importing and running locally is to allow GNI Radio's Python
    environment to be independent of VUnit's Python env.
    """
    print(f"Generating data for {config.name}")

    command = [
        p.join(ROOT, "gnuradio_data", "dvbs2_encoder_flow_diagram.py"),
        "--frame-type",
        config.frame_type.name,
        "--constellation",
        config.constellation.name,
        "--code-rate",
        config.code_rate.name,
    ]

    if not p.exists(config.test_files_path):
        os.makedirs(config.test_files_path)

    try:
        subp.check_output(command, cwd=config.test_files_path, stderr=subp.PIPE)
        with open(config.timestamp, "w") as fd:
            fd.write(time.asctime())
    except subp.CalledProcessError as exc:
        _logger.error(
            'Failed to generate GUN Radio data. Command used: "%s"\nResult:\n%s',
            " ".join(map(str, command)),
            exc.stderr.decode(),
        )
        raise

    # Generate the dvbs2_encoder_wrapper test files by inserting the metadata
    # into the data stream
    _addModcodToInputData(
        _getAcmCommandByte(
            config.frame_type, config.constellation, config.code_rate, False
        ),
        p.join(config.test_files_path, "input_data_packed.bin"),
        p.join(config.test_files_path, "input_data_with_metadata_pilots_off.bin"),
    )

    _addModcodToInputData(
        _getAcmCommandByte(
            config.frame_type, config.constellation, config.code_rate, True
        ),
        p.join(config.test_files_path, "input_data_packed.bin"),
        p.join(config.test_files_path, "input_data_with_metadata_pilots_on.bin"),
    )


def _addModcodToInputData(metadata: int, source: str, target: str):
    """
    Add in-band signalling according to ETSI EN 302 307 Appendix I.2
    """
    with open(target, "wb") as target_fd:
        target_fd.write(b"%c" % 0xB8)
        target_fd.write(b"%c" % metadata)
        with open(source, "rb") as source_fd:
            target_fd.write(source_fd.read())


def _generateGnuRadioData():
    """
    Generates GNU Radio data for configs whose test files can't found
    """
    configs = []

    for config in TEST_CONFIGS:
        if not p.exists(config.timestamp):
            configs += [config]

    # Generate needed data on a process pool to speed up things
    with Pool() as pool:
        pool.map(_runGnuRadio, configs)


LDPC_Q = {
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_4): 135,
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_3): 120,
    (FrameType.FECFRAME_NORMAL, CodeRate.C2_5): 108,
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_2): 90,
    (FrameType.FECFRAME_NORMAL, CodeRate.C3_5): 72,
    (FrameType.FECFRAME_NORMAL, CodeRate.C2_3): 60,
    (FrameType.FECFRAME_NORMAL, CodeRate.C3_4): 45,
    (FrameType.FECFRAME_NORMAL, CodeRate.C4_5): 36,
    (FrameType.FECFRAME_NORMAL, CodeRate.C5_6): 30,
    (FrameType.FECFRAME_NORMAL, CodeRate.C8_9): 20,
    (FrameType.FECFRAME_NORMAL, CodeRate.C9_10): 18,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_4): 36,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_3): 30,
    (FrameType.FECFRAME_SHORT, CodeRate.C2_5): 27,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_2): 25,
    (FrameType.FECFRAME_SHORT, CodeRate.C3_5): 18,
    (FrameType.FECFRAME_SHORT, CodeRate.C2_3): 15,
    (FrameType.FECFRAME_SHORT, CodeRate.C3_4): 12,
    (FrameType.FECFRAME_SHORT, CodeRate.C4_5): 10,
    (FrameType.FECFRAME_SHORT, CodeRate.C5_6): 8,
    (FrameType.FECFRAME_SHORT, CodeRate.C8_9): 5,
}

LDPC_LENGTH = {
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_4): 64_800 - 16_200,
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_3): 64_800 - 21_600,
    (FrameType.FECFRAME_NORMAL, CodeRate.C2_5): 64_800 - 25_920,
    (FrameType.FECFRAME_NORMAL, CodeRate.C1_2): 64_800 - 32_400,
    (FrameType.FECFRAME_NORMAL, CodeRate.C3_5): 64_800 - 38_880,
    (FrameType.FECFRAME_NORMAL, CodeRate.C2_3): 64_800 - 43_200,
    (FrameType.FECFRAME_NORMAL, CodeRate.C3_4): 64_800 - 48_600,
    (FrameType.FECFRAME_NORMAL, CodeRate.C4_5): 64_800 - 51_840,
    (FrameType.FECFRAME_NORMAL, CodeRate.C5_6): 64_800 - 54_000,
    (FrameType.FECFRAME_NORMAL, CodeRate.C8_9): 64_800 - 57_600,
    (FrameType.FECFRAME_NORMAL, CodeRate.C9_10): 64_800 - 58_320,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_4): 16_200 - 3_240,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_3): 16_200 - 5_400,
    (FrameType.FECFRAME_SHORT, CodeRate.C2_5): 16_200 - 6_480,
    (FrameType.FECFRAME_SHORT, CodeRate.C1_2): 16_200 - 7_200,
    (FrameType.FECFRAME_SHORT, CodeRate.C3_5): 16_200 - 9_720,
    (FrameType.FECFRAME_SHORT, CodeRate.C2_3): 16_200 - 10_800,
    (FrameType.FECFRAME_SHORT, CodeRate.C3_4): 16_200 - 11_880,
    (FrameType.FECFRAME_SHORT, CodeRate.C4_5): 16_200 - 12_600,
    (FrameType.FECFRAME_SHORT, CodeRate.C5_6): 16_200 - 13_320,
    (FrameType.FECFRAME_SHORT, CodeRate.C8_9): 16_200 - 14_400,
}

PLFRAME_HEADER_CONFIGS = {
    TestDefinition.fromConfigTuple(frame_type, constellation, code_rate, pilots)
    for frame_type, constellation, code_rate, pilots in (
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C8_9, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C8_9, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C3_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C8_9, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_2, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_3, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_4, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C2_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C3_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C8_9, False),
        #  (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C9_10, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C8_9, False),
        (
            FrameType.FECFRAME_NORMAL,
            ConstellationType.MOD_16APSK,
            CodeRate.C9_10,
            False,
        ),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C8_9, False),
        (
            FrameType.FECFRAME_NORMAL,
            ConstellationType.MOD_32APSK,
            CodeRate.C9_10,
            False,
        ),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C3_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C8_9, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C9_10, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_2, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_3, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_4, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C2_3, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C2_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C3_4, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C3_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C4_5, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C5_6, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C8_9, False),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C9_10, False),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_16APSK, CodeRate.C8_9, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C8_9, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C3_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_8PSK, CodeRate.C8_9, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_2, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_3, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C1_4, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C2_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C3_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C8_9, True),
        #  (FrameType.FECFRAME_SHORT, ConstellationType.MOD_QPSK, CodeRate.C9_10, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_16APSK, CodeRate.C8_9, True),
        (
            FrameType.FECFRAME_NORMAL,
            ConstellationType.MOD_16APSK,
            CodeRate.C9_10,
            True,
        ),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_32APSK, CodeRate.C8_9, True),
        (
            FrameType.FECFRAME_NORMAL,
            ConstellationType.MOD_32APSK,
            CodeRate.C9_10,
            True,
        ),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C3_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C8_9, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_8PSK, CodeRate.C9_10, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_2, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_3, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C1_4, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C2_3, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C2_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C3_4, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C3_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C4_5, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C5_6, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C8_9, True),
        (FrameType.FECFRAME_NORMAL, ConstellationType.MOD_QPSK, CodeRate.C9_10, True),
    )
}

# List specific valid 16 APSK and 32 APSK configs
CONSTELLATION_MAPPER_CONFIGS = (
    set(_getConfigs(constellations=(ConstellationType.MOD_QPSK,)))
    | set(_getConfigs(constellations=(ConstellationType.MOD_8PSK,)))
    | {
        TestDefinition.fromConfigTuple(frame_type, constellation, code_rate, pilots)
        for frame_type, constellation, code_rate, pilots in (
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C2_3,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_4,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C4_5,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C5_6,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C8_9,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C9_10,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_5,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C2_3,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_4,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C4_5,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C5_6,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C8_9,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_5,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C3_4,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C4_5,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C5_6,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C8_9,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C9_10,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C3_4,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C4_5,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C5_6,
                True,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C8_9,
                True,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C2_3,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_4,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C4_5,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C5_6,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C8_9,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C9_10,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_5,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C2_3,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_4,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C4_5,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C5_6,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C8_9,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_16APSK,
                CodeRate.C3_5,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C3_4,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C4_5,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C5_6,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C8_9,
                False,
            ),
            (
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_32APSK,
                CodeRate.C9_10,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C3_4,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C4_5,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C5_6,
                False,
            ),
            (
                FrameType.FECFRAME_SHORT,
                ConstellationType.MOD_32APSK,
                CodeRate.C8_9,
                False,
            ),
            # this should work but GNU Radio itself doesn't handle it for some
            # reason
            # (FrameType.FECFRAME_SHORT, ConstellationType.MOD_32APSK, CodeRate.C9_10),
        )
    }
)


def _populateLdpcTable(config: TestDefinition):  # pylint: disable=too-many-locals
    """
    Creates the unrolled binary LDPC table file for the LDPC encoder testbench
    a CSV file with coefficients (from DVB-S2 spec's appendices B and C).
    """
    bin_table_path = p.join(config.test_files_path, "ldpc_table.bin")
    text_table_path = p.join(config.test_files_path, "ldpc_table.txt")

    if p.exists(bin_table_path) and p.exists(text_table_path):
        return

    csv_table = p.join(
        ROOT,
        "misc",
        "ldpc",
        f"ldpc_table_{config.frame_type.name}_{config.code_rate.name}.csv",
    )

    print(
        f"Generating LDPC table for FECFRAME={config.frame_type.value}, "
        f'code rate={config.code_rate.value} using "{csv_table}" as reference. '
        f'Binary data will be written to "{config.test_files_path}"',
    )

    with open(csv_table, "r") as fd:
        table = [x.split(",") for x in fd.read().split("\n") if x]

    table_q = LDPC_Q[(config.frame_type, config.code_rate)]
    table_length = LDPC_LENGTH[(config.frame_type, config.code_rate)]
    word_cnt = 0

    bin_table: List[str] = []
    text_table: List[str] = []

    bin_table += ["# Offset, next, bit index"]

    # Each offset is 16 bits (to represent 64,800 bits of FECFRAME_NORMAL),
    # but we'll also embed the s_ldpc_next values into the file as well on a
    # byte, so data width will 24: data[16] is s_ldpc_next while data[15:0] is
    # the actual offset
    bit_index = 0

    for line in table:
        for _ in range(360):
            text_table += [f"{bit_index:5d} || "]
            for i, coefficient in enumerate(tuple(int(x) for x in line)):
                offset = (coefficient + (bit_index % 360) * table_q) % table_length
                bin_table += [f"{offset},{int(i == len(line) - 1)},{bit_index}"]

                text_table[-1] += f" {word_cnt:5d}, {offset:5d}  |"
                word_cnt += 1

            bit_index += 1

    with open(bin_table_path, "wb") as bin_table_fd:
        bin_table_fd.write(b"\n".join([bytes(x, encoding="utf8") for x in bin_table]))

    with open(text_table_path, "w") as text_table_fd:
        text_table_fd.write("\n".join(text_table))


def _getModulationTable(
    frame_type: FrameType, constellation: ConstellationType, code_rate: CodeRate
):
    """
    Returns the modulation table for a given config. Please note we're scaling
    the constellation radius to keep values between [-1, 1). Also, this is for
    refence only since the RAMs now come with the correct initial values for
    all configs
    """
    # pylint: disable=invalid-name
    if constellation == ConstellationType.MOD_QPSK:
        return (
            # QPSK
            (math.cos(math.pi / 4.0), math.sin(math.pi / 4.0)),
            (math.cos(7 * math.pi / 4.0), math.sin(7 * math.pi / 4.0)),
            (math.cos(3 * math.pi / 4.0), math.sin(3 * math.pi / 4.0)),
            (math.cos(5 * math.pi / 4.0), math.sin(5 * math.pi / 4.0)),
        )

    if constellation == ConstellationType.MOD_8PSK:
        return (
            (math.cos(math.pi / 4.0), math.sin(math.pi / 4.0)),
            (math.cos(0.0), math.sin(0.0)),
            (math.cos(4 * math.pi / 4.0), math.sin(4 * math.pi / 4.0)),
            (math.cos(5 * math.pi / 4.0), math.sin(5 * math.pi / 4.0)),
            (math.cos(2 * math.pi / 4.0), math.sin(2 * math.pi / 4.0)),
            (math.cos(7 * math.pi / 4.0), math.sin(7 * math.pi / 4.0)),
            (math.cos(3 * math.pi / 4.0), math.sin(3 * math.pi / 4.0)),
            (math.cos(6 * math.pi / 4.0), math.sin(6 * math.pi / 4.0)),
        )

    if constellation == ConstellationType.MOD_16APSK:
        r1 = 1.0
        r2 = 1.0
        if frame_type == FrameType.FECFRAME_NORMAL:
            r1 = {
                CodeRate.C2_3: r2 / 3.15,
                CodeRate.C3_4: r2 / 2.85,
                CodeRate.C4_5: r2 / 2.75,
                CodeRate.C5_6: r2 / 2.70,
                CodeRate.C8_9: r2 / 2.60,
                CodeRate.C9_10: r2 / 2.57,
                CodeRate.C3_5: r2 / 3.70,
            }.get(code_rate, 0.0)
        elif frame_type == FrameType.FECFRAME_SHORT:
            r1 = {
                CodeRate.C2_3: r2 / 3.15,
                CodeRate.C3_4: r2 / 2.85,
                CodeRate.C4_5: r2 / 2.75,
                CodeRate.C5_6: r2 / 2.70,
                CodeRate.C8_9: r2 / 2.60,
                CodeRate.C3_5: r2 / 3.70,
            }.get(code_rate, 0.0)

        # Needed since GNU Radio 3.8 (see https://github.com/gnuradio/gnuradio/commit/efe3e6c1)
        r0 = math.sqrt(4.0 / ((r1 * r1) + 3.0 * (r2 * r2)))
        r1 = r0 * r1
        r2 = r0 * r2

        scaling = max(r0, r1, r2)
        r0 = r0 / scaling
        r1 = r1 / scaling
        r2 = r2 / scaling

        return (
            (r2 * math.cos(math.pi / 4.0), r2 * math.sin(math.pi / 4.0)),
            (r2 * math.cos(-math.pi / 4.0), r2 * math.sin(-math.pi / 4.0)),
            (r2 * math.cos(3 * math.pi / 4.0), r2 * math.sin(3 * math.pi / 4.0)),
            (r2 * math.cos(-3 * math.pi / 4.0), r2 * math.sin(-3 * math.pi / 4.0)),
            (r2 * math.cos(math.pi / 12.0), r2 * math.sin(math.pi / 12.0)),
            (r2 * math.cos(-math.pi / 12.0), r2 * math.sin(-math.pi / 12.0)),
            (r2 * math.cos(11 * math.pi / 12.0), r2 * math.sin(11 * math.pi / 12.0)),
            (r2 * math.cos(-11 * math.pi / 12.0), r2 * math.sin(-11 * math.pi / 12.0)),
            (r2 * math.cos(5 * math.pi / 12.0), r2 * math.sin(5 * math.pi / 12.0)),
            (r2 * math.cos(-5 * math.pi / 12.0), r2 * math.sin(-5 * math.pi / 12.0)),
            (r2 * math.cos(7 * math.pi / 12.0), r2 * math.sin(7 * math.pi / 12.0)),
            (r2 * math.cos(-7 * math.pi / 12.0), r2 * math.sin(-7 * math.pi / 12.0)),
            (r1 * math.cos(math.pi / 4.0), r1 * math.sin(math.pi / 4.0)),
            (r1 * math.cos(-math.pi / 4.0), r1 * math.sin(-math.pi / 4.0)),
            (r1 * math.cos(3 * math.pi / 4.0), r1 * math.sin(3 * math.pi / 4.0)),
            (r1 * math.cos(-3 * math.pi / 4.0), r1 * math.sin(-3 * math.pi / 4.0)),
        )

    if constellation == ConstellationType.MOD_32APSK:
        r1 = 1.0
        r2 = 1.0
        r3 = 1.0
        r1 = {
            CodeRate.C3_4: r3 / 5.27,
            CodeRate.C4_5: r3 / 4.87,
            CodeRate.C5_6: r3 / 4.64,
            CodeRate.C8_9: r3 / 4.33,
            CodeRate.C9_10: r3 / 4.30,
        }.get(code_rate, 0.0)

        r2 = {
            CodeRate.C3_4: r1 * 2.84,
            CodeRate.C4_5: r1 * 2.72,
            CodeRate.C5_6: r1 * 2.64,
            CodeRate.C8_9: r1 * 2.54,
            CodeRate.C9_10: r1 * 2.53,
        }.get(code_rate, 0.0)

        # Needed since GNU Radio 3.8 (see https://github.com/gnuradio/gnuradio/commit/efe3e6c1)
        r0 = math.sqrt(8.0 / ((r1 * r1) + 3.0 * (r2 * r2) + 4.0 * (r3 * r3)))
        r1 *= r0
        r2 *= r0
        r3 *= r0

        scaling = max(r0, r1, r2, r3)
        r0 = r0 / scaling
        r1 = r1 / scaling
        r2 = r2 / scaling
        r3 = r3 / scaling

        return (
            (r2 * math.cos(math.pi / 4.0), r2 * math.sin(math.pi / 4.0)),
            (r2 * math.cos(5 * math.pi / 12.0), r2 * math.sin(5 * math.pi / 12.0)),
            (r2 * math.cos(-math.pi / 4.0), r2 * math.sin(-math.pi / 4.0)),
            (
                r2 * math.cos(-5 * math.pi / 12.0),
                r2 * math.sin(-5 * math.pi / 12.0),
            ),
            (r2 * math.cos(3 * math.pi / 4.0), r2 * math.sin(3 * math.pi / 4.0)),
            (r2 * math.cos(7 * math.pi / 12.0), r2 * math.sin(7 * math.pi / 12.0)),
            (r2 * math.cos(-3 * math.pi / 4.0), r2 * math.sin(-3 * math.pi / 4.0)),
            (
                r2 * math.cos(-7 * math.pi / 12.0),
                r2 * math.sin(-7 * math.pi / 12.0),
            ),
            (r3 * math.cos(math.pi / 8.0), r3 * math.sin(math.pi / 8.0)),
            (r3 * math.cos(3 * math.pi / 8.0), r3 * math.sin(3 * math.pi / 8.0)),
            (r3 * math.cos(-math.pi / 4.0), r3 * math.sin(-math.pi / 4.0)),
            (r3 * math.cos(-math.pi / 2.0), r3 * math.sin(-math.pi / 2.0)),
            (r3 * math.cos(3 * math.pi / 4.0), r3 * math.sin(3 * math.pi / 4.0)),
            (r3 * math.cos(math.pi / 2.0), r3 * math.sin(math.pi / 2.0)),
            (r3 * math.cos(-7 * math.pi / 8.0), r3 * math.sin(-7 * math.pi / 8.0)),
            (r3 * math.cos(-5 * math.pi / 8.0), r3 * math.sin(-5 * math.pi / 8.0)),
            (r2 * math.cos(math.pi / 12.0), r2 * math.sin(math.pi / 12.0)),
            (r1 * math.cos(math.pi / 4.0), r1 * math.sin(math.pi / 4.0)),
            (r2 * math.cos(-math.pi / 12.0), r2 * math.sin(-math.pi / 12.0)),
            (r1 * math.cos(-math.pi / 4.0), r1 * math.sin(-math.pi / 4.0)),
            (
                r2 * math.cos(11 * math.pi / 12.0),
                r2 * math.sin(11 * math.pi / 12.0),
            ),
            (r1 * math.cos(3 * math.pi / 4.0), r1 * math.sin(3 * math.pi / 4.0)),
            (
                r2 * math.cos(-11 * math.pi / 12.0),
                r2 * math.sin(-11 * math.pi / 12.0),
            ),
            (r1 * math.cos(-3 * math.pi / 4.0), r1 * math.sin(-3 * math.pi / 4.0)),
            (r3 * math.cos(0.0), r3 * math.sin(0.0)),
            (r3 * math.cos(math.pi / 4.0), r3 * math.sin(math.pi / 4.0)),
            (r3 * math.cos(-math.pi / 8.0), r3 * math.sin(-math.pi / 8.0)),
            (r3 * math.cos(-3 * math.pi / 8.0), r3 * math.sin(-3 * math.pi / 8.0)),
            (r3 * math.cos(7 * math.pi / 8.0), r3 * math.sin(7 * math.pi / 8.0)),
            (r3 * math.cos(5 * math.pi / 8.0), r3 * math.sin(5 * math.pi / 8.0)),
            (r3 * math.cos(math.pi), r3 * math.sin(math.pi)),
            (r3 * math.cos(-3 * math.pi / 4.0), r3 * math.sin(-3 * math.pi / 4.0)),
        )

    # pylint: enable=invalid-name

    return ()


def _createModulationTable(config: TestDefinition):
    """
    Creates the modulation table file to be used by axi_constellation_mapper_tb
    """
    target = p.join(config.test_files_path, "modulation_table.bin")

    if p.exists(target):
        return

    try:
        table = _getModulationTable(
            frame_type=config.frame_type,
            constellation=config.constellation,
            code_rate=config.code_rate,
        )
    except:
        print(
            f"Failed to generate modulation RAM contents for FECFRAME={config.frame_type.value}, "
            f"modulation={config.constellation.value}, code rate={config.code_rate.value}."
        )
        raise

    print(
        f"Generating modulation RAM contents for FECFRAME={config.frame_type.value}, "
        f"modulation={config.constellation.value}, code rate={config.code_rate.value}. "
        f'Data will be written to "{target}"',
    )

    with open(target, "wb") as fd:
        for cos, sin in table:
            fd.write(bytes(str(cos), encoding="utf8"))
            fd.write(b"\n")
            fd.write(bytes(str(sin), encoding="utf8"))
            fd.write(b"\n")


def _createAuxiliaryTables():
    """
    Creates the binary LDPC table files if they don't already exist
    """
    with Pool() as pool:
        pool.map(_populateLdpcTable, TEST_CONFIGS)
        pool.map(_createModulationTable, CONSTELLATION_MAPPER_CONFIGS)


class GhdlPragmaHandler:
    """
    Removes code between arbitraty pragmas
    -- ghdl translate_off
    this is ignored
    -- ghdl translate_on
    """

    _PRAGMA = re.compile(
        r"\s*--\s*ghdl\s+translate_off[\r\n].*?[\n\r]\s*--\s*ghdl\s+translate_on",
        flags=re.DOTALL | re.I | re.MULTILINE,
    )

    def run(self, code, file_name):  # pylint: disable=unused-argument,no-self-use
        """
        Removes text between "-- ghdl translate_off" and "-- ghdl translate_on"
        """
        # Lazy check to avoid running the regex unnecessarily
        for word in ("ghdl", "translate_on", "translate_off"):
            if word not in code:
                return code

        lines = code.split("\n")

        # Prepend the comment characters to lines within matches so line
        # numbers are kept
        for match in self._PRAGMA.finditer(code):
            for lnum in range(
                code[: match.start()].count("\n") + 1, code[: match.end()].count("\n")
            ):
                lines[lnum] = "-- " + lines[lnum]

        return "\n".join(lines)


def setupSources(vunit):
    """
    Sets up files and libraries
    """
    vunit.add_osvvm()
    vunit.add_com()
    vunit.enable_location_preprocessing()
    if vunit.get_simulator_name() == "ghdl":
        vunit.add_preprocessor(GhdlPragmaHandler())
    library = vunit.add_library("lib")
    library.add_source_files(p.join(ROOT, "rtl", "*.vhd"))
    library.add_source_files(p.join(ROOT, "rtl", "ldpc", "*.vhd"))
    library.add_source_files(p.join(ROOT, "third_party", "bch_generated", "*.vhd"))
    library.add_source_files(p.join(ROOT, "third_party", "airhdl", "*.vhd"))
    library.add_source_files(p.join(ROOT, "testbench", "*.vhd"))

    vunit.add_library("str_format").add_source_files(
        p.join(ROOT, "third_party", "hdl_string_format", "src", "*.vhd")
    )

    vunit.add_library("fpga_cores").add_source_files(
        p.join(ROOT, "third_party", "fpga_cores", "src", "*.vhd")
    )
    vunit.add_library("fpga_cores_sim").add_source_files(
        p.join(ROOT, "third_party", "fpga_cores", "sim", "*.vhd")
    )


def setupTests(vunit, args):
    """
    Creates tests for components
    """
    if args.individual_config_runs:
        # BCH and LDPC encoding don't depend on the constellation type, choose any
        for config in _getConfigs(constellations=(ConstellationType.MOD_8PSK,)):
            vunit.library("lib").entity("axi_bch_encoder_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    SEED=args.seed,
                    NUMBER_OF_TEST_FRAMES=8,
                ),
            )

            vunit.library("lib").entity("axi_ldpc_encoder_core_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    NUMBER_OF_TEST_FRAMES=3,
                ),
            )
            vunit.library("lib").entity("axi_ldpc_table_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    SEED=args.seed,
                    NUMBER_OF_TEST_FRAMES=3,
                ),
            )

        for config in CONSTELLATION_MAPPER_CONFIGS:
            vunit.library("lib").entity("axi_constellation_mapper_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    SEED=args.seed,
                    NUMBER_OF_TEST_FRAMES=3,
                ),
            )

    else:
        addAllConfigsTest(
            entity=vunit.library("lib").entity("axi_bch_encoder_tb"),
            configs=TEST_CONFIGS,
            seed=args.seed,
        )

        addAllConfigsTest(
            entity=vunit.library("lib").entity("axi_constellation_mapper_tb"),
            configs=CONSTELLATION_MAPPER_CONFIGS,
        )

        addAllConfigsTest(
            entity=vunit.library("lib").entity("axi_ldpc_encoder_core_tb"),
            configs=_getConfigs(
                constellations=(ConstellationType.MOD_8PSK,),
            ),
        )

        addAllConfigsTest(
            entity=vunit.library("lib").entity("axi_ldpc_table_tb"),
            configs=_getConfigs(
                constellations=(ConstellationType.MOD_8PSK,),
            ),
        )

        # Run the DVB S2 Tx testbench with a smaller sample of configs to check
        # integration, otherwise sim takes way too long. Note that when
        # --individual-config-runs is passed, all configs are added
        addAllConfigsTest(
            entity=vunit.library("lib").entity("dvbs2_encoder_tb"),
            configs=PLFRAME_HEADER_CONFIGS & CONSTELLATION_MAPPER_CONFIGS,
        )

    addAllConfigsTest(
        entity=vunit.library("lib").entity("axi_baseband_scrambler_tb"),
        seed=args.seed,
        configs=TEST_CONFIGS,
    )

    # axi_plframe_header does not support every combination out there
    if args.individual_config_runs:
        for config in PLFRAME_HEADER_CONFIGS:
            vunit.library("lib").entity("axi_plframe_header_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    NUMBER_OF_TEST_FRAMES=3,
                ),
            )
            vunit.library("lib").entity("axi_physical_layer_scrambler_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    NUMBER_OF_TEST_FRAMES=3,
                ),
            )
        for config in PLFRAME_HEADER_CONFIGS & CONSTELLATION_MAPPER_CONFIGS:
            vunit.library("lib").entity("dvbs2_encoder_tb").add_config(
                name=config.name,
                generics=dict(
                    test_cfg=config.getTestConfigString(),
                    NUMBER_OF_TEST_FRAMES=1,
                    SEED=args.seed,
                ),
            )

    else:
        addAllConfigsTest(
            vunit.library("lib").entity("axi_plframe_header_tb"),
            configs=PLFRAME_HEADER_CONFIGS,
        )
        addAllConfigsTest(
            vunit.library("lib").entity("axi_physical_layer_scrambler_tb"),
            configs=PLFRAME_HEADER_CONFIGS,
        )

    # Generate bit interleaver tests
    for data_width in (8,):
        all_configs = []
        for config in _getConfigs(
            constellations=(
                ConstellationType.MOD_8PSK,
                ConstellationType.MOD_16APSK,
                ConstellationType.MOD_32APSK,
            )
        ):
            all_configs += [config.getTestConfigString()]

            if args.individual_config_runs:
                vunit.library("lib").entity("axi_bit_interleaver_tb").add_config(
                    name=f"data_width={data_width},{config.name}",
                    generics=dict(
                        TDATA_WIDTH=data_width,
                        test_cfg=config.getTestConfigString(),
                        NUMBER_OF_TEST_FRAMES=8,
                        SEED=args.seed,
                    ),
                )

        if not args.individual_config_runs:
            vunit.library("lib").entity("axi_bit_interleaver_tb").add_config(
                name=f"data_width={data_width},all_parameters",
                generics=dict(
                    TDATA_WIDTH=data_width,
                    test_cfg="|".join(all_configs),
                    NUMBER_OF_TEST_FRAMES=2,
                    SEED=args.seed,
                ),
            )

    # Physical layer framer only connects axi_plframe_header and
    # axi_physical_layer_scrambler and both are tested individually, so we
    # don't need to test all configs
    vunit.library("lib").entity("axi_physical_layer_framer_tb").add_config(
        name="test",
        generics=dict(
            test_cfg=TestDefinition.fromConfigTuple(
                FrameType.FECFRAME_NORMAL,
                ConstellationType.MOD_QPSK,
                CodeRate.C1_2,
                False,
            ).getTestConfigString(),
            NUMBER_OF_TEST_FRAMES=3,
        ),
    )


def addAllConfigsTest(entity, configs, seed=0, name=None):
    """
    Adds a test config with all combinations of configurations (assuming both
    input and reference files ca be found)
    """
    params = []

    for config in configs:
        params += [config.getTestConfigString()]

    random.shuffle(params)

    assert params, "Could not find any config files!"

    entity.add_config(
        name=name or "test_all_configs",
        generics=dict(test_cfg="|".join(params), NUMBER_OF_TEST_FRAMES=1, SEED=seed),
    )


def main():
    "Main entry point for DVB FPGA test runner"

    _generateGnuRadioData()
    _createAuxiliaryTables()

    cli = VUnitCLI()
    cli.parser.add_argument(
        "--individual-config-runs",
        "-i",
        action="store_true",
        help="Create individual test runs for each configuration. By default, "
        "all combinations of frame types, code rates and modulations are "
        "tested in the same simulation",
    )
    cli.parser.add_argument(
        "--seed",
        action="store",
        help="Random seed of the tests",
        type=int,
        default=random.randint(-1 << 31, 1 << 31),  # VHDL integer range
    )

    args = cli.parse_args()

    print(f"Seed: {args.seed}")

    vunit = VUnit.from_args(args=args)
    setupSources(vunit)
    setupTests(vunit, args)

    vunit.set_compile_option("modelsim.vcom_flags", ["-explicit"])

    # Not all options are supported by all GHDL backends
    vunit.set_sim_option("ghdl.elab_flags", ["-frelaxed-rules"])
    vunit.set_compile_option("ghdl.a_flags", ["-frelaxed-rules", "-O2", "-g"])

    # Make components not bound (error 3473) an error
    vsim_flags = ["-error", "3473"]
    if args.gui:
        vsim_flags += ['-voptargs="+acc=n"']

    vunit.set_sim_option("modelsim.vsim_flags", vsim_flags)

    vunit.set_sim_option("disable_ieee_warnings", True)
    vunit.set_sim_option("modelsim.init_file.gui", p.join(ROOT, "wave.do"))
    vunit.main()


if __name__ == "__main__":
    sys.exit(main())
