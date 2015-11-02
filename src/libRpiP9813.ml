open Lib2Wires


(** This implementation is based on https://yadom.fr/downloadable/download/sample/sample_id/22/ *)
class p9813 ?(red=0x66) ?(green=0x2D) ?(blue=0x91) bus_init =
object (self)
	val bus = bus_init
	val mutable red = red
	val mutable green = green
	val mutable blue = blue
	initializer
		bus#init;
		self#refresh 
	method set_color r g b =
		red <- r land 0xFF;
		green <- g land 0xFF;
		blue <- b land 0xFF;
		self#refresh
	method refresh =
		(* Compute first byte *)
		let rgb_prime = 0b11000000 (* First 2 bits at 1 *)
			(* XORed blue's 7th and 6th bits *)
			lor (((0b10000000 land blue)  lsr 2) lxor 0b00100000)
			lor (((0b01000000 land blue)  lsr 2) lxor 0b00010000)
			(* XORed green's 7th and 6th bits *)
			lor (((0b10000000 land green) lsr 4) lxor 0b00001000)
			lor (((0b01000000 land green) lsr 4) lxor 0b00000100)
			(* XORed red's 7th and 6th bits *)
			lor (((0b10000000 land red)   lsr 6) lxor 0b00000010)
			lor (((0b01000000 land red)   lsr 6) lxor 0b00000001)
		(* It seems that I have a bug, P9813 uses 6 bits only. *)
		and o1 = (blue land 0xFC) lor (green lsr 6) 
		and o2 = ((green land 0x3C) lsl 2) lor (red lsr 4) 
		and o3 = ((red land 0xC) lsl 4)
		in
		bus#write_bytes [| 0;0;0;0 |];
		bus#write_bytes [|rgb_prime;o1;o2;o3|];
		bus#write_bytes [| 0;0;0;0 |];
end
