# ix_yukio
Yukio's interconnect

The modules are in src directory. There is a testbench for each module in testbench directory.

## parameters
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
