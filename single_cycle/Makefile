TB      ?= cpu_tb.sv
MODULES ?= datapath.sv \
			control.sv \
			alu.sv \
			regfile.sv \
			instrfile.sv \
			datafile.sv

OUT     ?= build/a.out
IVERILOG ?= iverilog
FLAGS   ?= -g2005-sv -Wall

.PHONY: tb build clean

tb: run

build: | $(BUILD)
	$(IVERILOG) $(FLAGS) -o $(OUT) $(TB) $(MODULES)

run: build
	cd build && vvp a.out

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)