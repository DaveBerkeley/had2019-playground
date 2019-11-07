CORE := synth

DEPS_synth := misc

RTL_SRCS_synth = $(addprefix rtl/, \
	rng.v \
	synth_attack_decay.v \
	synth_cfg_reg.v \
	synth_core.v \
	synth_mix.v \
	synth_reg.v \
	synth_wb.v \
)

TESTBENCHES_synth := \
	synth_tb \
	synth_attack_decay_tb \
	$(NULL)

include $(ROOT)/build/core-magic.mk