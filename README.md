# ix_yukio
Yukio's interconnect

The modules are in src directory. There is a testbench for each module in testbench directory.

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
 - NSBSB ... number of SBs connected to one DSB. NSBSB must be less than or equal to min(NCLBMAC, NCLBMEM).
 - NMAC ... number of MAC modules in a big-tile
 - NMEM ... number of MEM modules in a big-tile
 - EXTIN ... number of external input-pins in each io block
 - EXTOUT ... number of external output-pins in each io block
 - EXTDATAIN ... number of external input-words in each data io block
 - EXTDATAOUT ... number of external input-words in each data io block

I define a big-tile as a figure below. It has one column for MAC and MEM in the middle. There may be multiple MAC modules and MEM modules in one big-tile, then the MAC modules are placed upper than all of the MEM modules. On the edges of FPGA, there are io blocks, one for each SB on the edges, two for each SB at the corners. There are also data io blocks for DSBs.

fpga.v in fpgatop branch implements this, but it has problems and yet to be simulated. iverilog ran into internal errors (buffer overflaw) when I increased some parameters. verilator seems to have problems in 2D array. Anyway it might help you understand how these parameters should be treated.

![図1](https://user-images.githubusercontent.com/18373300/96968489-01fd3000-154c-11eb-8ab9-a37260a91608.png)

## modules
The signals starting with "c" represent configuration bits.
 - transmission_gate.v
 
 ![transmission_gate](https://user-images.githubusercontent.com/18373300/96963877-6916e680-1544-11eb-9ea9-bd1d7e27087b.png)
 
 - transmission_gate_oneway.v
 
 I use this cell when one of the data is not inout. This enables verilator to compile the modules. The cell design of this module would be the same as transmission_gate.v.
 
 ![transmission_gate_oneway](https://user-images.githubusercontent.com/18373300/96965087-88af0e80-1546-11eb-9fac-6c1be11b2027.png)
 
 - switch_box_element_one.v
 
 ![switch_box_element_one](https://user-images.githubusercontent.com/18373300/96963948-8ba8ff80-1544-11eb-9c01-2999a1ba817a.png)

 - switch_box_element_two.v
 
 ![switch_box_element_two](https://user-images.githubusercontent.com/18373300/96964090-cdd24100-1544-11eb-9fa0-d4afc307939f.png)

 - disjoint_switch_box.v
 
 ![disjoint_swtich_box](https://user-images.githubusercontent.com/18373300/96964199-03772a00-1545-11eb-9d46-d5ad477a92df.png)
 
 - universal_switch_box.v
   - When W is even
   
   ![universal_swtich_box](https://user-images.githubusercontent.com/18373300/96964412-5b159580-1545-11eb-838c-4de78d1e9f40.png)
   
   - When W is odd
   
   ![universal_swtich_box_odd](https://user-images.githubusercontent.com/18373300/96964226-0eca5580-1545-11eb-9a7a-5e316d419d48.png)
 
 - clb_switch_box.v
 
 one universal switch box for single lines and the following circuit for double lines.
 
 ![universal_swtich_box_double](https://user-images.githubusercontent.com/18373300/96964553-a16af480-1545-11eb-9dc0-19efc26c21c4.png)
 
 - connection_block.v
 
 The number of inputs of CLB is CLBIN, but only first  CLBIN0(CLBIN1) bits are connected to the tracks. When CLBX, a boolean parameter, is 1, there are direct connections. The number of switches for each output is limited by a parameter, and the place of switches is shifted per output. The amount of the last shift is passed to the next connection block as a bias.
 
 ![connection_block](https://user-images.githubusercontent.com/18373300/96964599-b9427880-1545-11eb-88cd-175456e18784.png)

 - data_connection_block.v
 
 For data input/output for MAC/MEM.
 
 ![data_connection_block](https://user-images.githubusercontent.com/18373300/96966034-12aba700-1548-11eb-9e36-c9936c738c75.png)

 - control_connection_block.v
 
 For control (address) input for MAC/MEM.
 
 ![control_connection_block](https://user-images.githubusercontent.com/18373300/96966636-1ab81680-1549-11eb-916d-e4433f3d66b9.png)

 - io_block.v
 
 ![io_block](https://user-images.githubusercontent.com/18373300/96966388-abdabd80-1548-11eb-8a05-bddb7e26197c.png)
 
 - data_io_block.v
 
 ![data_io_block](https://user-images.githubusercontent.com/18373300/96966742-5bb02b00-1549-11eb-87e3-4a54d98da72f.png)
 
 - switch_box_connector.v
 
 Just connecting wires under modulus. Short circuit should not happen because the other end of wire can be 1'bz in switch boxes.
 
 ![switch_box_connector v](https://user-images.githubusercontent.com/18373300/96971586-4a1e5180-1550-11eb-927b-afd4af3f2a82.png)

