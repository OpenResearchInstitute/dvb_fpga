# dvbs2_encoder

|||
| --- | --- |
| **Description** | n/a |
| **Default base address** | `0x0` |
| **Register width** | 32 bits |
| **Default address width** | 32 bits |
| **Register count** | 47 |
| **Range** | 4888 bytes |
| **Revision** | 347 |

## Overview

| Offset | Name | Description | Type |
| --- | --- | --- | --- |
| `0x0` | config |  | REG |
| `0x4` | ldpc_fifo_status |  | REG |
| `0x8` | frames_in_transit |  | REG |
| `0x10` | constellation_map_radius_ram | Radius for 16APSK and 32APSK constellation mapping.R0 uses bits 15:0, R1 uses bits 31:16.For 32APSK, r3 is always 1.0, so r1 and r0 need to be scaled appropriatelyOffsets:- 0x00: Short frames,  16APSK, 2/3- 0x01: Short frames,  16APSK, 3/4- 0x02: Short frames,  16APSK, 3/5- 0x03: Short frames,  16APSK, 4/5- 0x04: Short frames,  16APSK, 5/6- 0x05: Short frames,  16APSK, 8/9- 0x06: Normal frames, 16APSK, 2/3- 0x07: Normal frames, 16APSK, 3/4- 0x08: Normal frames, 16APSK, 3/5- 0x09: Normal frames, 16APSK, 4/5- 0x0a: Normal frames, 16APSK, 5/6- 0x0b: Normal frames, 16APSK, 8/9- 0x0c: Normal frames, 16APSK, 9/10- 0x0d: Short frames,  32APSK, 3/4- 0x0e: Short frames,  32APSK, 4/5- 0x0f: Short frames,  32APSK, 5/6- 0x10: Short frames,  32APSK, 8/9- 0x11: Normal frames, 32APSK, 3/4- 0x12: Normal frames, 32APSK, 4/5- 0x13: Normal frames, 32APSK, 5/6- 0x14: Normal frames, 32APSK, 8/9- 0x15: Normal frames, 32APSK, 9/10 | MEM[22] |
| `0x110` | constellation_map_iq_ram | IQ values for QPSK, 8PSK, 16APSK and 32APSK constellation mapping.I component uses bits 15:0, Q component uses bits 31:16.Offsets:- 0x00 to 0x03: QPSK- 0x04 to 0x0B: 8PSK- 0x0C to 0x1B: 16APSK- 0x1C to 0x3B: 32APSK | MEM[60] |
| `0xD00` | axi_debug_input_width_converter_cfg |  | REG |
| `0xD04` | axi_debug_input_width_converter_frame_count |  | REG |
| `0xD08` | axi_debug_input_width_converter_last_frame_length |  | REG |
| `0xD0C` | axi_debug_input_width_converter_min_max_frame_length |  | REG |
| `0xD10` | axi_debug_input_width_converter_word_count |  | REG |
| `0xD14` | axi_debug_input_width_converter_strobes |  | REG |
| `0xE00` | axi_debug_bb_scrambler_cfg |  | REG |
| `0xE04` | axi_debug_bb_scrambler_frame_count |  | REG |
| `0xE08` | axi_debug_bb_scrambler_last_frame_length |  | REG |
| `0xE0C` | axi_debug_bb_scrambler_min_max_frame_length |  | REG |
| `0xE10` | axi_debug_bb_scrambler_word_count |  | REG |
| `0xE14` | axi_debug_bb_scrambler_strobes |  | REG |
| `0xF00` | axi_debug_bch_encoder_cfg |  | REG |
| `0xF04` | axi_debug_bch_encoder_frame_count |  | REG |
| `0xF08` | axi_debug_bch_encoder_last_frame_length |  | REG |
| `0xF0C` | axi_debug_bch_encoder_min_max_frame_length |  | REG |
| `0xF10` | axi_debug_bch_encoder_word_count |  | REG |
| `0xF14` | axi_debug_bch_encoder_strobes |  | REG |
| `0x1000` | axi_debug_ldpc_encoder_cfg |  | REG |
| `0x1004` | axi_debug_ldpc_encoder_frame_count |  | REG |
| `0x1008` | axi_debug_ldpc_encoder_last_frame_length |  | REG |
| `0x100C` | axi_debug_ldpc_encoder_min_max_frame_length |  | REG |
| `0x1010` | axi_debug_ldpc_encoder_word_count |  | REG |
| `0x1014` | axi_debug_ldpc_encoder_strobes |  | REG |
| `0x1100` | axi_debug_bit_interleaver_cfg |  | REG |
| `0x1104` | axi_debug_bit_interleaver_frame_count |  | REG |
| `0x1108` | axi_debug_bit_interleaver_last_frame_length |  | REG |
| `0x110C` | axi_debug_bit_interleaver_min_max_frame_length |  | REG |
| `0x1110` | axi_debug_bit_interleaver_word_count |  | REG |
| `0x1114` | axi_debug_bit_interleaver_strobes |  | REG |
| `0x1200` | axi_debug_constellation_mapper_cfg |  | REG |
| `0x1204` | axi_debug_constellation_mapper_frame_count |  | REG |
| `0x1208` | axi_debug_constellation_mapper_last_frame_length |  | REG |
| `0x120C` | axi_debug_constellation_mapper_min_max_frame_length |  | REG |
| `0x1210` | axi_debug_constellation_mapper_word_count |  | REG |
| `0x1214` | axi_debug_constellation_mapper_strobes |  | REG |
| `0x1300` | axi_debug_plframe_cfg |  | REG |
| `0x1304` | axi_debug_plframe_frame_count |  | REG |
| `0x1308` | axi_debug_plframe_last_frame_length |  | REG |
| `0x130C` | axi_debug_plframe_min_max_frame_length |  | REG |
| `0x1310` | axi_debug_plframe_word_count |  | REG |
| `0x1314` | axi_debug_plframe_strobes |  | REG |

## Registers

| Offset | Name | Description | Type | Access | Attributes | Reset |
| ---    | --- | --- | --- | --- | --- | --- |
| `0x0` | config | | REG | R/W |  | `0x1` |
|        |  [17:0] physical_layer_scrambler_shift_reg_init | Initial value for the physical layer's scrambler X vector, used to set a device's gold code. |  |  |  | `0x1` |
|        |  [18] enable_dummy_frames |  |  |  |  | `0x0` |
|        |  [19] swap_input_data_byte_endianness | Changes input data byte endianness. Has no effect if input data width is 8. |  |  |  | `0x0` |
|        |  [20] swap_output_data_byte_endianness |  |  |  |  | `0x0` |
|        |  [21] force_output_ready | Ignores external m_tready and force the internal value to 1 |  |  |  | `0x0` |
| `0x4` | ldpc_fifo_status | | REG | R |  | `0x0` |
|        |  [13:0] ldpc_fifo_entries |  |  |  |  | `0x0` |
|        |  [16] ldpc_fifo_empty |  |  |  |  | `0x0` |
|        |  [17] ldpc_fifo_full |  |  |  |  | `0x0` |
|        |  [21:20] arbiter_selected |  |  |  |  | `0x0` |
| `0x8` | frames_in_transit | | REG | R |  | `0x0` |
|        |  [7:0] value |  |  |  |  | `0x0` |
| `0x10` | constellation_map_radius_ram |Radius for 16APSK and 32APSK constellation mapping.R0 uses bits 15:0, R1 uses bits 31:16.For 32APSK, r3 is always 1.0, so r1 and r0 need to be scaled appropriatelyOffsets:- 0x00: Short frames,  16APSK, 2/3- 0x01: Short frames,  16APSK, 3/4- 0x02: Short frames,  16APSK, 3/5- 0x03: Short frames,  16APSK, 4/5- 0x04: Short frames,  16APSK, 5/6- 0x05: Short frames,  16APSK, 8/9- 0x06: Normal frames, 16APSK, 2/3- 0x07: Normal frames, 16APSK, 3/4- 0x08: Normal frames, 16APSK, 3/5- 0x09: Normal frames, 16APSK, 4/5- 0x0a: Normal frames, 16APSK, 5/6- 0x0b: Normal frames, 16APSK, 8/9- 0x0c: Normal frames, 16APSK, 9/10- 0x0d: Short frames,  32APSK, 3/4- 0x0e: Short frames,  32APSK, 4/5- 0x0f: Short frames,  32APSK, 5/6- 0x10: Short frames,  32APSK, 8/9- 0x11: Normal frames, 32APSK, 3/4- 0x12: Normal frames, 32APSK, 4/5- 0x13: Normal frames, 32APSK, 5/6- 0x14: Normal frames, 32APSK, 8/9- 0x15: Normal frames, 32APSK, 9/10 | MEM[22] | R/W | read latency: 2 | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0x110` | constellation_map_iq_ram |IQ values for QPSK, 8PSK, 16APSK and 32APSK constellation mapping.I component uses bits 15:0, Q component uses bits 31:16.Offsets:- 0x00 to 0x03: QPSK- 0x04 to 0x0B: 8PSK- 0x0C to 0x1B: 16APSK- 0x1C to 0x3B: 32APSK | MEM[60] | R/W | read latency: 2 | `0x0` |
|        |  [31:0] value |  |  |  |  | `0x0` |
| `0xD00` | axi_debug_input_width_converter_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0xD04` | axi_debug_input_width_converter_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xD08` | axi_debug_input_width_converter_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xD0C` | axi_debug_input_width_converter_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0xD10` | axi_debug_input_width_converter_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xD14` | axi_debug_input_width_converter_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0xE00` | axi_debug_bb_scrambler_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0xE04` | axi_debug_bb_scrambler_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xE08` | axi_debug_bb_scrambler_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xE0C` | axi_debug_bb_scrambler_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0xE10` | axi_debug_bb_scrambler_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xE14` | axi_debug_bb_scrambler_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0xF00` | axi_debug_bch_encoder_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0xF04` | axi_debug_bch_encoder_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xF08` | axi_debug_bch_encoder_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xF0C` | axi_debug_bch_encoder_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0xF10` | axi_debug_bch_encoder_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0xF14` | axi_debug_bch_encoder_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0x1000` | axi_debug_ldpc_encoder_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0x1004` | axi_debug_ldpc_encoder_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1008` | axi_debug_ldpc_encoder_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x100C` | axi_debug_ldpc_encoder_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0x1010` | axi_debug_ldpc_encoder_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1014` | axi_debug_ldpc_encoder_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0x1100` | axi_debug_bit_interleaver_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0x1104` | axi_debug_bit_interleaver_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1108` | axi_debug_bit_interleaver_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x110C` | axi_debug_bit_interleaver_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0x1110` | axi_debug_bit_interleaver_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1114` | axi_debug_bit_interleaver_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0x1200` | axi_debug_constellation_mapper_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0x1204` | axi_debug_constellation_mapper_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1208` | axi_debug_constellation_mapper_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x120C` | axi_debug_constellation_mapper_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0x1210` | axi_debug_constellation_mapper_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1214` | axi_debug_constellation_mapper_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |
| `0x1300` | axi_debug_plframe_cfg | | REG | R/W |  | `0x0` |
|        |  [0] block_data | Disables data from passing through |  |  |  | `0x0` |
|        |  [1] allow_word | Allows a single word to pass through. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
|        |  [2] allow_frame | Allow a single frame to complete. Needs `block_data` to be set before setting this. |  |  | self-clearing | `0x0` |
| `0x1304` | axi_debug_plframe_frame_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1308` | axi_debug_plframe_last_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x130C` | axi_debug_plframe_min_max_frame_length | | REG | R |  | `0x0` |
|        |  [15:0] min_frame_length |  |  |  |  | `0x0` |
|        |  [31:16] max_frame_length |  |  |  |  | `0x0` |
| `0x1310` | axi_debug_plframe_word_count | | REG | R |  | `0x0` |
|        |  [15:0] value |  |  |  |  | `0x0` |
| `0x1314` | axi_debug_plframe_strobes | | REG | R |  | `0x0` |
|        |  [0] s_tvalid |  |  |  |  | `0x0` |
|        |  [1] s_tready |  |  |  |  | `0x0` |
|        |  [2] m_tvalid |  |  |  |  | `0x0` |
|        |  [3] m_tready |  |  |  |  | `0x0` |

_Generated on 2023-01-08 at 17:59 (UTC) by airhdl version 2023.01.1-740440560_
