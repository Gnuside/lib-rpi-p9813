open Lib2Wires;;
open LibRpiP9813;;
open Unix;;

let pin_clk = 9 and pin_data = 8;;
let bus = new twoWiresDriver (pin_clk, pin_data, TWO_WIRES_DOWN, TWO_WIRES_READ_UP);;

let series = [|
	[| 0xFF ; 0x00 ; 0x00 |];
	[| 0x00 ; 0xFF ; 0x00 |];
	[| 0x00 ; 0x00 ; 0xFF |];
	[| 0x00 ; 0x00 ; 0x00 |];
	[| 0xFF ; 0xFF ; 0xFF |];
|];;

let red = ref 0x66
and green = ref 0x2D
and blue = ref 0x91
and loop = ref false
;;

Arg.parse [
	("-loop", Arg.Set(loop), "run an internal RGB loop");
	("-red", Arg.Set_int(red), "set red value");
	("-green", Arg.Set_int(green), "set green value");
	("-blue", Arg.Set_int(blue), "set blue value");
] ignore "set colors or run an internal color loop";;

let led_ctl = new p9813 ~red:(!red) ~green:(!green) ~blue:(!blue) bus;;

if !loop then sleep 4;

while !loop do
	Array.iter (function colors -> begin
		sleep 2;
		led_ctl#set_color colors.(2) colors.(1) colors.(0)
	end) series
done
