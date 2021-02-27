import numpy as np
from gnuradio import filter

samp_rate=10e6
rolloff=0.2
taps=100

coeffs_floating = filter.firdes.root_raised_cosine(1.0, samp_rate, samp_rate/2, rolloff, taps) 

output_width = 16

factor = 0.5

coeffs_fixed_twos = []
for coeff in coeffs_floating:

    if coeff < 0:
        coeffs_fixed_twos.append( 0xFFFF & int(np.floor(((factor*coeff) + 2**output_width) * 2**(output_width-1))) )
    else:
        coeffs_fixed_twos.append( 0xFFFF & int(np.floor((factor*coeff) * 2**(output_width-1))) )

    print("x%04X" % coeffs_fixed_twos[-1])


