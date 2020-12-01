
lef read /home/miyasaka/pdk/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd.tlef
if {  [info exist ::env(EXTRA_LEFS)] } {
	set lefs_in $::env(EXTRA_LEFS)
	foreach lef_file $lefs_in {
		lef read $lef_file
	}
}
def read /openLANE_flow/designs/clb_tile/runs/16-11_06-11/results/routing/clb_tile.def
load clb_tile -dereference
cd /openLANE_flow/designs/clb_tile/runs/16-11_06-11/results/magic/
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
# extract warn all
extract

ext2spice lvs
ext2spice clb_tile.ext
feedback save /openLANE_flow/designs/clb_tile/runs/16-11_06-11/logs/magic/magic_ext2spice.feedback.txt
# exec cp clb_tile.spice /openLANE_flow/designs/clb_tile/runs/16-11_06-11/results/magic/clb_tile.spice

