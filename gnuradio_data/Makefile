frame_lengths := FECFRAME_NORMAL
modulation_values := MOD_8PSK MOD_16APSK MOD_32APSK
code_rates := C1_2 C1_3 C1_4 C2_3 C2_5 C3_4 C3_5 C4_5 C5_6 C8_9 C9_10


dvbs2_tx.py: dvbs2_frame_sync.grc
	grcc $^ -d $(PWD)

define ruletemp
$1_$2_$3/run.py: dvbs2_tx.py
	mkdir -p $$$$(dirname $$@)          && \
	sed -e 's/\<FECFRAME_NORMAL\>/$1/g'    \
			-e 's/\<MOD_16APSK\>/$2/g'         \
			-e 's/\<C9_10\>/$3/g' $$^ > $$@ && \
	chmod +x $$@                        && \
	cd $$$$(dirname $$@)                && \
	./run.py
all:: $1_$2_$3/run.py
endef

$(foreach frame_length,$(frame_lengths), \
	$(foreach modulation,$(modulation_values), \
		$(foreach code_rate,$(code_rates), \
	$(eval $(call ruletemp,$(frame_length),$(modulation),$(code_rate))))))

# frame_lengths := FECFRAME_NORMAL FECFRAME_SHORT
# modulation_values := MOD_8PSK MOD_16APSK MOD_32APSK
# code_rates := C9_10

# all: FECFRAME_NORMAL_MOD_16APSK_C2_3/run.py FECFRAME_NORMAL_MOD_16APSK_C9_10/run.py FECFRAME_NORMAL_MOD_32APSK_C2_3/run.py FECFRAME_NORMAL_MOD_32APSK_C9_10/run.py FECFRAME_NORMAL_MOD_8PSK_C2_3/run.py FECFRAME_NORMAL_MOD_8PSK_C9_10/run.py
