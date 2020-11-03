vcs_clock_period = 1.6
input_delay = 0$(shell echo "scale=4; ${vcs_clock_period}*0.2" | bc)

base_dir = $(CURDIR)
src_dir = $(base_dir)/src
tb_dir = $(base_dir)/testbench
sim_rundir := ./sim-rundir

top := tranif1_tb
tb := $(tb_dir)/$(top).v

sim_vsrcs := \
	$(wildcard $(src_dir)/*.vh) \
	$(wildcard $(src_dir)/*.v) \
	$(tb) \

VCS = vcs -full64
VCS_OPTS = -notice -line +lint=all,noVCDE,noONGS,noUI +warn=noTMR -error=PCWM-L -timescale=1ns/10ps -quiet \
	+incdir+$(src_dir) \
	+v2k +vcs+lic+wait \
	+vcs+initreg+random \
	+vcs+loopdetect \
	+vcs+loopreport \
	+rad \
	-v2005 \
	-debug_pp \
	+define+INPUT_DELAY=$(input_delay) \
	+define+CLOCK_PERIOD=$(vcs_clock_period) \
	$(sim_vsrcs) \


# Compile the simulator.
simv = $(sim_rundir)/simv
.PHONY: $(simv)
$(simv):
	mkdir -p $(sim_rundir) && \
	cd $(sim_rundir) && \
	$(VCS) $(VCS_OPTS) -o $(notdir $@) -top $(top) \
	+define+DEBUG -debug_pp \

# Run the simulator.
.PHONY: $(simv)-exec
$(simv)-exec: $(simv)
	$(simv) -q +ntb_random_seed_automatic

test:	$(simv)-exec
