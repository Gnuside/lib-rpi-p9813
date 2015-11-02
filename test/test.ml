open Lib2Wires;;

let pin_clk = 9 and pin_data = 8;;
let bus = new twoWiresDriver (pin_clk, pin_data, TWO_WIRES_DOWN, TWO_WIRES_READ_UP);;

bus#init;

print_string "Writing sequence...";
bus#write_bytes [| 0; 0 ; 0 ; 0 ; 0b11111111 ; 0xF0 ; 0xF0 ; 0xF0 |];
print_endline "Done.";
