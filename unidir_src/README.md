# ix_yukio
Yukio's unidirectional interconnect

The modules are in this directory (unidir_src). There is a testbench for each module in the directory unidir_testbench.

## modules
The signals starting with "c" represent configuration bits.

 - switch_box_element_one.v
 
 ![switch_box_element_one_uni](https://user-images.githubusercontent.com/18373300/99109900-e1953280-262c-11eb-8116-9cbf9aab4b42.png)

 - switch_box_element_two.v
 
 ![switch_box_element_two_uni](https://user-images.githubusercontent.com/18373300/99111212-08ecff00-262f-11eb-87da-f60223caffd9.png)

 - disjoint_switch_box.v
 
 ![disjoint_switch_box_uni](https://user-images.githubusercontent.com/18373300/99112503-160aed80-2631-11eb-9731-cd6c8d60ec4a.png)
 
 - universal_switch_box.v
   
   north[x] means the pair of north_in[x] and north_out[x]. The same for the other directions.
   - When W is even
   
   ![universal_swtich_box_uni](https://user-images.githubusercontent.com/18373300/99112886-b95c0280-2631-11eb-9f87-e16842ded108.png)   
  
   - When W is odd
   
   ![universal_swtich_box_odd_uni](https://user-images.githubusercontent.com/18373300/99113313-60d93500-2632-11eb-92f1-58eb15c6ac38.png)
   
 - clb_switch_box.v
 
 One universal switch box for single lines and the following circuit for double lines. The configuration bits are concatenated as {conf_for_double, conf_for_single}.
 
 ![universal_swtich_box_double](https://user-images.githubusercontent.com/18373300/96964553-a16af480-1545-11eb-9dc0-19efc26c21c4.png)
 
 - connection_block.v
 
 The number of inputs of CLB is CLBIN, but only first  CLBIN0(CLBIN1) bits are connected to the tracks. When CLBX, a boolean parameter, is 1, there are direct connections (CLB's outputs are connected to the MUX of the other CLB's each input). For each direction, CLBOS single-tracks are the outputs of MUXs selecting from the input track and the CLBs' outputs, while the other tracks are just the input tracks. The same for the first half of the double-tracks, the latter half are always directly used (because half of double-tracks should go thorough a connection block without updated). The tracks where the MUXs with CLBs' outputs are placed are shifted by CLBOS\*CLBOS_BIAS%WS for single-tracks, CLBOD\*CLBOD_BIAS%(WD/2) for double-tracks. To change the tracks to be updated in another connectoin block, CLBOS_BIAS should be incremented by 1 after each connection block, and CLBOB_BIAS by 1 after every two connection blocks (remember double-tracks are swapped in switch box).
 
 ![connection_block_uni](https://user-images.githubusercontent.com/18373300/99128134-655f1700-264d-11eb-9bd5-ea04d06f6bbf.png)

 - data_connection_block.v
 
 For data input/output for MAC/MEM.
 
 ![data_connection_block_uni](https://user-images.githubusercontent.com/18373300/99138886-73299200-2677-11eb-88b4-f7dca1007719.png)

 - control_connection_block.v
 
 For control (address) input for MAC/MEM.
 
 ![control_connection_block_uni](https://user-images.githubusercontent.com/18373300/99139044-b33d4480-2678-11eb-832d-8fbcd2425b0f.png)

 - io_block.v
 
 - data_io_block.v
 
 - switch_box_connector.v
 
 Just connecting wires under modulus. Short circuit should not happen because the other end of wire can be 1'bz in switch boxes.


## parameters
### parameters from modules
 - CLBIN ... number of input-bits to one CLB
 - CLBOUT ... number of output-bits of one CLB
 - CARRY ... number of carry-bits passed between CLBs
 - WW ... unit word width
 - MACDATAIN ... number of input-words to one MAC module (WW*MACDATAIN input bits)
 - MACDATAOUT ... number of output-words of one MAC module
 - MACCONTROLIN ... number of control-bits to one MAC module
 - NCLBMAC ... number of CLB-rows per one MAC-row (MAC/CLB in terms of height)
 - MEMDATAIN
 - MEMDATAOUT
 - MEMCONTROLIN
 - NCLBMEM
### parameters to top module
 - N ... number of big-tiles vertically
 - M ... number of big-tiles horizontally
 - WS ... number of bits (tracks) in each single line
 - WD ... number of bits in each double line. WD must be multiple of 2
 - WG ... number of bits in each global line
 - WN ... number of words in the line around MAC/MEM modules (WN * WW bits)
 - CLBOS ... number of the switches to connect each output of CLB to the single line tracks
 - CLBOD ... number of the switches to connect each output of CLB to the double line tracks
 - CLBIOTYPE ... 0 -> anyside with MUX, 1 -> left to right or right to left with MUX, 2 -> divided (CLBIN and CLBOUT must be multiple of 4)
 - CLBX ... a boolean value to toggle using direct connection between adjacent CLBs
 - CARRYTYPE ... 0 -> anyside with MUX, 1 -> vertical two-way and horizontal one-way only at the top and bottom with MUX, 2 -> one-way meandering (top to bottom -> left to right -> bottom to top -> left to right -> ...)
 - MCLB ... number of CLB-columns in a big-tileset. MCLB must be multiple of 2.
 - NSB ... No horizontal line and SB when ROW%NSB != 0 (except near io block and MAC/MEM). CLBIOTYPE must not be 2 when NSB is not 1. This is for layered interconnect.
 - NSBMAC/NSBMEM ... number of SBs connected to one DSB. NSBSB must be less than or equal to NCLBMAC/NCLBMEM.
 - NMAC ... number of MAC modules in a big-tile
 - NMEM ... number of MEM modules in a big-tile
 - EXTIN ... number of external input-pins in each io block
 - EXTOUT ... number of external output-pins in each io block
 - EXTDATAIN ... number of external input-words in each data io block
 - EXTDATAOUT ... number of external input-words in each data io block

I define a big-tile as a figure below. It has one column for MAC and MEM in the middle. There may be multiple MAC modules and MEM modules in one big-tile, then the MAC modules are placed upper than all of the MEM modules. On the edges of FPGA, there are io blocks, one for each SB on the edges, two for each SB at the corners. There are also data io blocks for DSBs.

fpga.v in fpgatop branch implements this, but it has problems and yet to be simulated. iverilog ran into internal errors (buffer overflaw) when I increased some parameters. verilator seems to have problems in 2D array. Anyway it might help you understand how these parameters should be treated.

![図2](https://user-images.githubusercontent.com/18373300/96973575-07aa4400-1553-11eb-8530-51e3b2d9d46c.png)
