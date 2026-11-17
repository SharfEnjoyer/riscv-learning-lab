TB      ?= ../tb/multicycle_tb.sv
MODULES ?= datapath.sv \
			control.sv \
			alu.sv \
			regfile.sv \
			instrfile.sv \
			datafile.sv

OUT     ?= build/a.out
IVERILOG ?= iverilog
FLAGS   ?= -g2005-sv -Wall
BUILD 	?= build

.PHONY: tb build clean

tb: run

build: | build_dec
	$(IVERILOG) $(FLAGS) -o $(OUT) $(TB) $(MODULES)

run: | build
	cd $(BUILD) && vvp a.out

build_dec:
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)