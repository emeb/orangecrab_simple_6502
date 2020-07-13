# orangecrab_simple_6502
A very simple 6502 system running on an Orange Crab FPGA board

## prerequisites
To build this you will need the following FPGA tools

* Trellis - Lattice ECP5 FPGA project https://github.com/SymbiFlow/prjtrellis
* Yosys - Synthesis https://github.com/YosysHQ/yosys
* Nextpnr - Place and Route https://github.com/YosysHQ/nextpnr

You will also need the following 6502 tools:

* cc65 6502 C compiler (for default option) https://github.com/cc65/cc65

## Building

	git clone https://github.com/emeb/orangecrab_simple_6502
	cd orangecrab_simple_6502
	git submodule update --init
	cd trellis
	make

## Running

Plug the Orange Crab USB in and load the previously built bitstream .

	make prog

The RGB LED should begin flashing a binary sequence.

## CPU coding

By default the build system fills the ROM with code based on the C and assembly
source in the cc65 directory. If you are modifying only the C or assembly code
then you can do a partial rebuild that changes only the ROM contents which will
complete somewhat more quickly using the following command:

	make recode

within the icestorm directory. 

## Thanks

Thanks to the developers of all the tools used for this, as well as the authors
of the IP core I snagged for the 6502. I've added that as a submodule
so you'll know where to get it and who to give credit to.
