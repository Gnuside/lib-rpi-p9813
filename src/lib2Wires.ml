open WiringPi;;

(* ################# Name of pins : ################# *)
(* ################# on Raspberry : ################# *)
(* +----------+-Rev2-+------+--------+------+-------+ *)
(* | wiringPi | GPIO | Phys | Name   | Mode | Value | *)
(* +----------+------+------+--------+------+-------+ *)
(* |      0   |  17  |  11  | GPIO 0 | IN   | Low   | *)
(* |      1   |  18  |  12  | GPIO 1 | IN   | High  | *)
(* |      2   |  27  |  13  | GPIO 2 | IN   | High  | *)
(* |      3   |  22  |  15  | GPIO 3 | IN   | High  | *)
(* |      4   |  23  |  16  | GPIO 4 | IN   | Low   | *)
(* |      5   |  24  |  18  | GPIO 5 | IN   | Low   | *)
(* |      6   |  25  |  22  | GPIO 6 | IN   | High  | *)
(* |      7   |   4  |   7  | GPIO 7 | IN   | High  | *)
(* |      8   |   2  |   3  | SDA    | IN   | High  | *)
(* |      9   |   3  |   5  | SCL    | IN   | High  | *)
(* |     10   |   8  |  24  | CE0    | IN   | High  | *)
(* |     11   |   7  |  26  | CE1    | IN   | Low   | *)
(* |     12   |  10  |  19  | MOSI   | IN   | High  | *)
(* |     13   |   9  |  21  | MISO   | IN   | High  | *)
(* |     14   |  11  |  23  | SCLK   | IN   | High  | *)
(* |     15   |  14  |   8  | TxD    | ALT0 | High  | *)
(* |     16   |  15  |  10  | RxD    | ALT0 | High  | *)
(* |     17   |  28  |   3  | GPIO 8 | OUT  | High  | *)
(* |     18   |  29  |   4  | GPIO 9 | IN   | Low   | *)
(* |     19   |  30  |   5  | GPIO10 | IN   | Low   | *)
(* |     20   |  31  |   6  | GPIO11 | IN   | Low   | *)
(* +----------+------+------+--------+------+-------+ *)
type pin_t = 
	| TWO_WIRES_GPIO_0
	| TWO_WIRES_GPIO_1
	| TWO_WIRES_GPIO_2
	| TWO_WIRES_GPIO_3
	| TWO_WIRES_GPIO_4
	| TWO_WIRES_GPIO_5
	| TWO_WIRES_GPIO_6
	| TWO_WIRES_GPIO_7
	| TWO_WIRES_GPIO_8
	| TWO_WIRES_GPIO_9
	| TWO_WIRES_GPIO_10
	| TWO_WIRES_GPIO_11
	| TWO_WIRES_SCL
	| TWO_WIRES_SDA
	| TWO_WIRES_CE0
	| TWO_WIRES_CE1
	| TWO_WIRES_MOSI
	| TWO_WIRES_MISO
	| TWO_WIRES_SCLK
	| TWO_WIRES_TxD
	| TWO_WIRES_RxD

and level_t =
	| TWO_WIRES_DOWN
and reading_level_t =
	| TWO_WIRES_READ_UP
;;
(** This class allow you to create a two Wires protocol based on one
 * clock line and one data line.
 * The parameters allow you to choose the :
 *   - the clock pin : the pin where the clock will be made
 *   - the data pin : the pin on which the data will be transmited
 *   - the default level : Which level must take the line when no data is transmited
 *   - the reading level : defines whne data is read
 *)
class twoWiresDriver (clk_pin, data_pin, default_level, read_level) =
object (self)
	val clk_pin = clk_pin
	val data_pin = data_pin
	val default_lvl = default_level
	val read_lvl = read_level
	val us_delay = 100 (* delay used in micro_seconds *)
	(** This function sets up the port *)
	method init =
		print_string "Setting up line with pin ";
		print_int clk_pin; print_string " (clk) and ";
		print_int data_pin; print_string " (data)... ";
		print_int (setup ()); print_string "..."; (* The setup function needs to be run in root :'( *)
		pinMode clk_pin 1;
		digitalWrite clk_pin 0;
		pinMode data_pin 1;
		digitalWrite data_pin 0;
		print_endline "Done."
	(** Only generate one clk cycle on the clock line *)
	method private do_clk () =
		digitalWrite clk_pin 1;
		delayMicroseconds us_delay;
		digitalWrite clk_pin 0
	method write_byte ?(bit_lvl=8) byte =
		let bit = if (byte land 0x80) = 0 then 0 else 1 in
		delayMicroseconds 80;
		digitalWrite data_pin bit;
		self#do_clk ();
		if bit_lvl >= 0 then self#write_byte ~bit_lvl:(bit_lvl-1) (byte lsl 1)
		else begin
			delayMicroseconds us_delay;
			digitalWrite data_pin 0; (* reset to 0 *)
		end
	method write_bytes bytes =
		Array.iter self#write_byte bytes
end;;
		
