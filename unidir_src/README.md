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

 - clb_tile.v
 
 <img width="135" alt="clb_tile" src="https://user-images.githubusercontent.com/18373300/99140255-6f037180-2683-11eb-9cec-bf5dfbe0239a.png">
 
 - data_tile.v
 
 <img width="272" alt="data_tile" src="https://user-images.githubusercontent.com/18373300/99140252-6dd24480-2683-11eb-8dea-dc961f0e7d94.png">

