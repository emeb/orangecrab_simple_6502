# orangecrab_simple_6502
A very simple 6502 system running on an Orange Crab FPGA board

This demo shows an 8-bit 6502 CPU with modest RAM, ROM and I/O running on
the Orange Crab V0.2 hardware. It includes enough GPIO to flash the onboard
RGB LED, a 9600bps serial port on the IO 0 & 1 pins, and a USB device with 
CDC ACM serial emulation.

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

If you have a 9600bps serial device connected to IO 0 & 1 you will see a
short greeting message and the device waits for a connection on the USB
device. Once USB is connected, send <space> to the USB port and a similar
greeting will be printed on the USB port, after which the RGB LED should
begin flashing a binary sequence and text sent from the host to the USB
port will be echoed on both the USB and serial ports.

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
