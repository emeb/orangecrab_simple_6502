# Makefile for trellis tools + yosys + nextpnr
# 07-12-20 E. Brombaugh
# this version builds the CPU code from C

# src directory
VPATH = ../src/ ../verilog-6502/

SRC =	orangecrab_6502.v ../src/tst_6502.v ../src/acia.v \
		../verilog-6502/cpu.v ../verilog-6502/ALU.v \
		../src/acia_rx.v ../src/acia_tx.v

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
	
%.bit: %.config $(REAL_HEX)
	$(ECPBRAM) -f $(FAKE_HEX) -t $(REAL_HEX) -i $< -o temp.config
	$(ECPPACK) --compress --freq 38.8 --input temp.config --bit $@

%.dfu : %.bit
	cp $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

prog: $(PROJ).dfu
	sudo dfu-util -D $(PROJ).dfu
	
recode:
	rm -f $(REAL_HEX) $(PROJ).bin
	$(MAKE) prog
    
lint: $(SRC)
	$(VERILATOR) --lint-only -Wall --top-module $(PROJ) $(TECH_LIB) $(SRC)

clean:
	rm -f *.json *.config *.rpt *.bit *.dfu *.hex
	$(MAKE) clean -C ../cc65/

.SECONDARY:
.PHONY: all prog clean