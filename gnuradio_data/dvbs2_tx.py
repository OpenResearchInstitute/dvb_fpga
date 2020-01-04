#!/usr/bin/env python2
# -*- coding: utf-8 -*-
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

##################################################
# GNU Radio Python Flow Graph
# Title: Dvbs2 Tx
# Generated: Sat Jan  4 13:55:02 2020
##################################################


from gnuradio import analog
from gnuradio import blocks
from gnuradio import digital
from gnuradio import dtv
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from optparse import OptionParser
import math
import numpy


BASE_FRAME_LENGTH = {
    dtv.FECFRAME_SHORT: 16200,
    dtv.FECFRAME_NORMAL: 64800
    }

CODE_RATES = {
    dtv.C1_2:  1./2,
    dtv.C1_3:  1./3,
    dtv.C1_4:  1./4,
    dtv.C2_3:  2./3,
    dtv.C2_5:  2./5,
    dtv.C3_4:  3./4,
    dtv.C3_5:  3./5,
    dtv.C4_5:  4./5,
    dtv.C5_6:  5./6,
    dtv.C8_9:  8./9,
    dtv.C9_10: 9./10}

def get_crc_length(frame_type, code_rate):
    if frame_type == dtv.FECFRAME_SHORT:
        return 192

    if code_rate in (dtv.C8_9, dtv.C9_10):
        return 128
    if code_rate in (dtv.C5_6, dtv.C2_3):
        return 160

    return 192

class dvbs2_tx(gr.top_block):

    def __init__(self, modulation, frame_type, code_rate):
        gr.top_block.__init__(self, "Dvbs2 Tx")

        ##################################################
        # Parameters
        ##################################################
        frame_length = BASE_FRAME_LENGTH[frame_type]
        print("Base frame length: %d" % frame_length)
        frame_length = int(round(CODE_RATES[code_rate] * frame_length))
        print("Base frame length: %d" % frame_length)
        # Take off CRC
        frame_length -= get_crc_length(frame_type, code_rate)
        # Header is 10 bytes
        frame_length -= 80
        print("Base frame length: %d" % frame_length)
        frame_length /= 8
        print("Base frame length: %d" % frame_length)
        self.frame_length = frame_length

        ##################################################
        # Variables
        ##################################################
        self.symbol_rate = symbol_rate = 5000000
        self.taps = taps = 100
        self.samp_rate = samp_rate = symbol_rate * 2
        self.rolloff = rolloff = 0.2
        self.noise = noise = 0
        self.gain = gain = 1
        self.center_freq = center_freq = 1280e6

        ##################################################
        # Blocks
        ##################################################
        self.ldpc_encoder_input = blocks.file_sink(gr.sizeof_char*1, 'ldpc_encoder_input.bin', False)
        self.ldpc_encoder_input.set_unbuffered(False)
        self.fir_filter_xxx_0_0 = filter.fir_filter_ccc(1, (numpy.conj([0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j]  + [0,]*(89-32))))
        self.fir_filter_xxx_0_0.declare_sample_delay(0)
        self.fir_filter_xxx_0 = filter.fir_filter_ccc(1, (numpy.conj([0,]*(89-25) + [   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 - 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 1.00000j,   0.00000 + 0.00000j])))
        self.fir_filter_xxx_0.declare_sample_delay(0)
        self.fft_filter_xxx_0 = filter.fft_filter_ccc(1, (firdes.root_raised_cosine(1.0, samp_rate, samp_rate/2, rolloff, taps)), 1)
        self.fft_filter_xxx_0.declare_sample_delay(0)
        self.dtv_dvbs2_physical_cc_0 = dtv.dvbs2_physical_cc(frame_type, code_rate, dtv.MOD_BPSK, dtv.PILOTS_ON, 0)
        self.dtv_dvbs2_modulator_bc_0 = dtv.dvbs2_modulator_bc(frame_type,
        code_rate, dtv.MOD_BPSK, dtv.INTERPOLATION_OFF)
        self.dtv_dvbs2_interleaver_bb_0 = dtv.dvbs2_interleaver_bb(frame_type, code_rate, modulation)
        self.dtv_dvb_ldpc_bb_0 = dtv.dvb_ldpc_bb(dtv.STANDARD_DVBS2, frame_type, code_rate, dtv.MOD_OTHER)
        self.dtv_dvb_bch_bb_0 = dtv.dvb_bch_bb(dtv.STANDARD_DVBS2, frame_type, code_rate)
        self.dtv_dvb_bbscrambler_bb_0 = dtv.dvb_bbscrambler_bb(dtv.STANDARD_DVBS2, frame_type, code_rate)
        self.dtv_dvb_bbheader_bb_0 = dtv.dvb_bbheader_bb(dtv.STANDARD_DVBS2, frame_type, code_rate, dtv.RO_0_20, dtv.INPUTMODE_NORMAL, dtv.INBAND_OFF, 168, 4000000)
        self.digital_pfb_clock_sync_xxx_0 = digital.pfb_clock_sync_ccf(2, math.pi/100.0, (firdes.root_raised_cosine(2*32, 32, 1.0/float(2), 0.35, 11*2*32)), 32, 16, 1.5, 1)
        self.digital_costas_loop_cc_0 = digital.costas_loop_cc(math.pi/100.0, 4, False)
        self.blocks_throttle_0 = blocks.throttle(gr.sizeof_float*1, samp_rate/10,True)
        self.blocks_sub_xx_0 = blocks.sub_cc(1)
        self.blocks_multiply_xx_0 = blocks.multiply_vcc(1)
        self.blocks_multiply_const_vxx_0 = blocks.multiply_const_vcc((gain, ))
        self.blocks_max_xx_0 = blocks.max_ff(1,1)
        self.blocks_file_sink_1 = blocks.file_sink(gr.sizeof_float*1, 'output.bin', False)
        self.blocks_file_sink_1.set_unbuffered(False)
        self.blocks_delay_0 = blocks.delay(gr.sizeof_gr_complex*1, 1)
        self.blocks_conjugate_cc_0 = blocks.conjugate_cc()
        self.blocks_complex_to_mag_0_0 = blocks.complex_to_mag(1)
        self.blocks_complex_to_mag_0 = blocks.complex_to_mag(1)
        self.blocks_add_xx_2 = blocks.add_vcc(1)
        self.blocks_add_xx_0 = blocks.add_vcc(1)
        self.bit_interleaver_output = blocks.file_sink(gr.sizeof_char*1, 'bit_interleaver_output.bin', False)
        self.bit_interleaver_output.set_unbuffered(False)
        self.bit_interleaver_input = blocks.file_sink(gr.sizeof_char*1, 'bit_interleaver_input.bin', False)
        self.bit_interleaver_input.set_unbuffered(False)
        self.bch_encoder_input = blocks.file_sink(gr.sizeof_char*1, 'bch_encoder_input.bin', False)
        self.bch_encoder_input.set_unbuffered(False)
        self.analog_random_source_x_0 = blocks.vector_source_b(map(int, numpy.random.randint(0, 255, frame_length)), False)
        self.analog_noise_source_x_1 = analog.noise_source_c(analog.GR_GAUSSIAN, noise, 0)
        self.analog_agc_xx_0 = analog.agc_cc(1e-4, 1.0, 1.0)
        self.analog_agc_xx_0.set_max_gain(8192)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.analog_agc_xx_0, 0), (self.digital_pfb_clock_sync_xxx_0, 0))
        self.connect((self.analog_noise_source_x_1, 0), (self.blocks_add_xx_2, 1))
        self.connect((self.analog_random_source_x_0, 0), (self.dtv_dvb_bbheader_bb_0, 0))
        self.connect((self.blocks_add_xx_0, 0), (self.blocks_complex_to_mag_0, 0))
        self.connect((self.blocks_add_xx_2, 0), (self.analog_agc_xx_0, 0))
        self.connect((self.blocks_complex_to_mag_0, 0), (self.blocks_max_xx_0, 1))
        self.connect((self.blocks_complex_to_mag_0_0, 0), (self.blocks_max_xx_0, 0))
        self.connect((self.blocks_conjugate_cc_0, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.blocks_delay_0, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_max_xx_0, 0), (self.blocks_throttle_0, 0))
        self.connect((self.blocks_multiply_const_vxx_0, 0), (self.fft_filter_xxx_0, 0))
        self.connect((self.blocks_multiply_xx_0, 0), (self.fir_filter_xxx_0, 0))
        self.connect((self.blocks_multiply_xx_0, 0), (self.fir_filter_xxx_0_0, 0))
        self.connect((self.blocks_sub_xx_0, 0), (self.blocks_complex_to_mag_0_0, 0))
        self.connect((self.blocks_throttle_0, 0), (self.blocks_file_sink_1, 0))
        self.connect((self.digital_costas_loop_cc_0, 0), (self.blocks_conjugate_cc_0, 0))
        self.connect((self.digital_costas_loop_cc_0, 0), (self.blocks_delay_0, 0))
        self.connect((self.digital_pfb_clock_sync_xxx_0, 0), (self.digital_costas_loop_cc_0, 0))
        self.connect((self.dtv_dvb_bbheader_bb_0, 0), (self.dtv_dvb_bbscrambler_bb_0, 0))
        self.connect((self.dtv_dvb_bbscrambler_bb_0, 0), (self.bch_encoder_input, 0))
        self.connect((self.dtv_dvb_bbscrambler_bb_0, 0), (self.dtv_dvb_bch_bb_0, 0))
        self.connect((self.dtv_dvb_bch_bb_0, 0), (self.dtv_dvb_ldpc_bb_0, 0))
        self.connect((self.dtv_dvb_bch_bb_0, 0), (self.ldpc_encoder_input, 0))
        self.connect((self.dtv_dvb_ldpc_bb_0, 0), (self.bit_interleaver_input, 0))
        self.connect((self.dtv_dvb_ldpc_bb_0, 0), (self.dtv_dvbs2_interleaver_bb_0, 0))
        self.connect((self.dtv_dvbs2_interleaver_bb_0, 0), (self.bit_interleaver_output, 0))
        self.connect((self.dtv_dvbs2_interleaver_bb_0, 0), (self.dtv_dvbs2_modulator_bc_0, 0))
        self.connect((self.dtv_dvbs2_modulator_bc_0, 0), (self.dtv_dvbs2_physical_cc_0, 0))
        self.connect((self.dtv_dvbs2_physical_cc_0, 0), (self.blocks_multiply_const_vxx_0, 0))
        self.connect((self.fft_filter_xxx_0, 0), (self.blocks_add_xx_2, 0))
        self.connect((self.fir_filter_xxx_0, 0), (self.blocks_add_xx_0, 0))
        self.connect((self.fir_filter_xxx_0, 0), (self.blocks_sub_xx_0, 0))
        self.connect((self.fir_filter_xxx_0_0, 0), (self.blocks_add_xx_0, 1))
        self.connect((self.fir_filter_xxx_0_0, 0), (self.blocks_sub_xx_0, 1))

    def get_frame_length(self):
        return self.frame_length

    def set_frame_length(self, frame_length):
        self.frame_length = frame_length

    def get_symbol_rate(self):
        return self.symbol_rate

    def set_symbol_rate(self, symbol_rate):
        self.symbol_rate = symbol_rate
        self.set_samp_rate(self.symbol_rate * 2)

    def get_taps(self):
        return self.taps

    def set_taps(self, taps):
        self.taps = taps
        self.fft_filter_xxx_0.set_taps((firdes.root_raised_cosine(1.0, self.samp_rate, self.samp_rate/2, self.rolloff, self.taps)))

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.fft_filter_xxx_0.set_taps((firdes.root_raised_cosine(1.0, self.samp_rate, self.samp_rate/2, self.rolloff, self.taps)))
        self.blocks_throttle_0.set_sample_rate(self.samp_rate/10)

    def get_rolloff(self):
        return self.rolloff

    def set_rolloff(self, rolloff):
        self.rolloff = rolloff
        self.fft_filter_xxx_0.set_taps((firdes.root_raised_cosine(1.0, self.samp_rate, self.samp_rate/2, self.rolloff, self.taps)))

    def get_noise(self):
        return self.noise

    def set_noise(self, noise):
        self.noise = noise
        self.analog_noise_source_x_1.set_amplitude(self.noise)

    def get_gain(self):
        return self.gain

    def set_gain(self, gain):
        self.gain = gain
        self.blocks_multiply_const_vxx_0.set_k((self.gain, ))

    def get_center_freq(self):
        return self.center_freq

    def set_center_freq(self, center_freq):
        self.center_freq = center_freq


def argument_parser():
    parser = OptionParser(usage="%prog: [options]", option_class=eng_option)
    parser.add_option("--frame-type", default="FECFRAME_NORMAL", choices=("FECFRAME_NORMAL", "FECFRAME_SHORT"))
    parser.add_option("--modulation", default="MOD_8PSK", choices=("MOD_8PSK", "MOD_16APSK", "MOD_32APSK"))
    parser.add_option("--code-rate", default="C1_2", choices=("C1_2", "C1_3", "C1_4", "C2_3", "C2_5", "C3_4", "C3_5", "C4_5", "C5_6", "C8_9", "C9_10"))

    args, _ = parser.parse_args()

    args.frame_type = getattr(dtv, args.frame_type)
    args.modulation = getattr(dtv, args.modulation)
    args.code_rate = getattr(dtv, args.code_rate)

    print(args)

    return args


def main(top_block_cls=dvbs2_tx, options=None):
    args = argument_parser()

    #  def __init__(self, modulation, frame_type, code_rate):
    tb = top_block_cls(modulation=args.modulation, frame_type=args.frame_type, code_rate=args.code_rate)
    tb.start()
    tb.wait()


if __name__ == '__main__':
    main()
