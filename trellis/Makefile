# Makefile for trellis tools + yosys + nextpnr
# 07-12-20 E. Brombaugh
# this version builds the CPU code from C

# src directory
VPATH = ../src/ ../verilog-6502/ ../tinyfpga_bx_usbserial/usb

SRC =	orangecrab_6502.v ../src/tst_6502.v ../src/acia.v \
		../verilog-6502/cpu.v ../verilog-6502/ALU.v \
		../src/acia_rx.v ../src/acia_tx.v ../src/usb_serial.v \
		../tinyfpga_bx_usbserial/usb/usb_uart_core.v \
		../tinyfpga_bx_usbserial/usb/edge_detect.v \
		../tinyfpga_bx_usbserial/usb/serial.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_pe.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_in_arb.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_in_pe.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_out_arb.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_out_pe.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_rx.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_tx_mux.v \
		../tinyfpga_bx_usbserial/usb/usb_fs_tx.v \
		../tinyfpga_bx_usbserial/usb/usb_reset_det.v \
		../tinyfpga_bx_usbserial/usb/usb_serial_ctrl_ep.v \
		../tinyfpga_bx_usbserial/usb/usb_uart_bridge_ep.v

# preparing the machine code
FAKE_HEX =	rom.hex
REAL_HEX =  code.hex

# project stuff
PROJ = orangecrab_6502
PIN_DEF = orangecrab_6502.pcf
DEVICE = 25k
PACKAGE = CSFBGA285

YOSYS = yosys
NEXTPNR = nextpnr-ecp5
NEXTPNR_ARGS = --pre-pack $(SDC)
ECPPACK = ecppack
ECPBRAM = ecpbram
VERILATOR = verilator
TECH_LIB = /usr/local/share/yosys/ecp5/cells_sim.v

all: ${PROJ}.dfu

$(FAKE_HEX):
	$(ECPBRAM) -w 8 -d 4096 -g $(FAKE_HEX)

%.json: $(SRC) $(FAKE_HEX)
	$(YOSYS) -p 'synth_ecp5 -top $(PROJ) -json $@' $(SRC)

%.config: %.json $(PIN_DEF) 
	$(NEXTPNR) --json $< --textcfg $@ --$(DEVICE) --package $(PACKAGE) --lpf $(PIN_DEF)

$(REAL_HEX):
	$(MAKE) -C ../cc65/
	cp ../cc65/$(FAKE_HEX) ./$(REAL_HEX)

%_ram.config : %.config $(REAL_HEX)
	$(ECPBRAM) -f $(FAKE_HEX) -t $(REAL_HEX) -i $< -o $@

%.bit: %_ram.config
	$(ECPPACK) --compress --freq 38.8 --input $< --bit $@

%.svf: %_ram.config
	$(ECPPACK) --compress --freq 38.8 --input $< --svf $@

%.dfu : %.bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

prog: $(PROJ).dfu
	sudo dfu-util -D $(PROJ).dfu

jtag: $(PROJ).svf
	openocd -f openocd_jlink.ocd -c "svf -tap lfe5u25.tap -quiet $(PROJ).svf ; shutdown"
	
recode:
	rm -f $(REAL_HEX) $(PROJ).bit $(PROJ).dfu
	$(MAKE) prog
    
lint: $(SRC)
	$(VERILATOR) --lint-only -Wall --top-module $(PROJ) $(TECH_LIB) $(SRC)

clean:
	rm -f *.json *.config *.rpt *.bit *.svf *.dfu *.hex
	$(MAKE) clean -C ../cc65/

.SECONDARY:
.PHONY: all prog clean
