#
# core-rules.mk
#

# Save value
THIS_CORE := $(CORE)

# Default tools
IVERILOG ?= iverilog

ECP5_INCLUDES ?= -I$(shell yosys-config --datdir/ecp5/)
ECP5_LIBS ?= $(shell yosys-config --datdir/ecp5/cells_sim.v)


# Must be first rule and call it 'all' by convention
all: sim

# Root directory
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

# Temporary build-directory
BUILD_TMP := $(abspath build-tmp)

$(BUILD_TMP):
	mkdir -p $(BUILD_TMP)

# Discover all cores
$(foreach core_dir, $(wildcard $(ROOT)/cores/*), $(eval include $(core_dir)/core.mk))

# Resolve dependency tree for project and collect sources
$(BUILD_TMP)/core-deps.mk: Makefile $(BUILD_TMP) $(BUILD_TMP)/deps-core-$(THIS_CORE)
	@echo "include $(BUILD_TMP)/deps-core-*" > $@
	@echo "CORE_ALL_DEPS := \$$(DEPS_SOLVE_TMP)" >> $@
	@echo "CORE_ALL_RTL_SRCS := \$$(RTL_SRCS_SOLVE_TMP)" >> $@
	@echo "CORE_ALL_SIM_SRCS := \$$(SIM_SRCS_SOLVE_TMP)" >> $@
	@echo "CORE_ALL_PREREQ := \$$(PREREQ_SOLVE_TMP)" >> $@

include $(BUILD_TMP)/core-deps.mk

# Include path
CORE_SYNTH_INCLUDES := $(addsuffix /rtl/, $(addprefix -I$(ROOT)/cores/, $(CORE_ALL_DEPS)))
CORE_SIM_INCLUDES   := $(addsuffix /sim/, $(addprefix -I$(ROOT)/cores/, $(CORE_ALL_DEPS)))


# Simulation
$(BUILD_TMP)/%_tb: sim/%_tb.v $(ECP5_LIBS) $(CORE_ALL_PREREQ) $(CORE_ALL_RTL_SRCS) $(CORE_ALL_SIM_SRCS)
	iverilog -Wall -DSIM=1 -o $@ \
		$(CORE_SYNTH_INCLUDES) $(CORE_SIM_INCLUDES) $(ECP5_INCLUDES) \
		$(addprefix -l, $(ECP5_LIBS) $(CORE_ALL_RTL_SRCS) $(CORE_ALL_SIM_SRCS)) \
		$<


# Action targets
sim: $(addprefix $(BUILD_TMP)/, $(TESTBENCHES_$(THIS_CORE)))

clean:
	@rm -Rf $(BUILD_TMP)


.PHONY: all sim clean
