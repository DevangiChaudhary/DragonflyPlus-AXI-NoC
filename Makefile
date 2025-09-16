# Makefile for Dragonfly+ NoC Simulation
SIMULATOR = iverilog
SIM_FLAGS = -g2012 -Wall
VCD_VIEWER = gtkwave

# Output files
VCD_FILE = noc_simulation.vcd
EXECUTABLE = noc_sim
LOG_FILE = simulation.log

# Top-level module and testbench files
TOP_LEVEL = NOC.v
TESTBENCH = NoCtestbench.v

# File list - all your 200 files (198 + 2 new files)
VERILOG_FILES = \
	fifo.v \
	gpu1.v \
	gpu2.v \
	gpu3.v \
	gpu4.v \
	gpu5.v \
	gpu6.v \
	gpu7.v \
	gpu8.v \
	gpu9.v \
	gpu10.v \
	gpu11.v \
	gpu12.v \
	gpu13.v \
	gpu14.v \
	gpu15.v \
	gpu16.v \
	gpu17.v \
	gpu18.v \
	gpu19.v \
	gpu20.v \
	gpu21.v \
	gpu22.v \
	gpu23.v \
	gpu24.v \
	gpu25.v \
	gpu26.v \
	gpu27.v \
	gpu28.v \
	gpu29.v \
	gpu30.v \
	gpu31.v \
	gpu32.v \
	gpuni1router1.v \
	gpuni2router2.v \
	gpuni3router3.v \
	gpuni4router4.v \
	gpuni5router1.v \
	gpuni6router2.v \
	gpuni7router3.v \
	gpuni8router4.v \
	gpuni9router1.v \
	gpuni10router2.v \
	gpuni11router3.v \
	gpuni12router4.v \
	gpuni13router1.v \
	gpuni14router2.v \
	gpuni15router3.v \
	gpuni16router4.v \
	gpuni17router1.v \
	gpuni18router2.v \
	gpuni19router3.v \
	gpuni20router4.v \
	gpuni21router1.v \
	gpuni22router2.v \
	gpuni23router3.v \
	gpuni24router4.v \
	gpuni25router1.v \
	gpuni26router2.v \
	gpuni27router3.v \
	gpuni28router4.v \
	gpuni29router1.v \
	gpuni30router2.v \
	gpuni31router3.v \
	gpuni32router4.v \
	group1.v \
	group2.v \
	group3.v \
	group4.v \
	group5.v \
	group6.v \
	group7.v \
	group8.v \
	leaffsm1.v \
	leaffsm2.v \
	leaffsm3.v \
	leaffsm4.v \
	leaffsm5.v \
	leaffsm6.v \
	leaffsm7.v \
	leaffsm8.v \
	leafport.v \
	leafrouter1.v \
	leafrouter2.v \
	leafrouter3.v \
	leafrouter4.v \
	leafrouter5.v \
	leafrouter6.v \
	leafrouter7.v \
	leafrouter8.v \
	leafrouter9.v \
	leafrouter10.v \
	leafrouter11.v \
	leafrouter12.v \
	leafrouter13.v \
	leafrouter14.v \
	leafrouter15.v \
	leafrouter16.v \
	leafrouter17.v \
	leafrouter18.v \
	leafrouter19.v \
	leafrouter20.v \
	leafrouter21.v \
	leafrouter22.v \
	leafrouter23.v \
	leafrouter24.v \
	leafrouter25.v \
	leafrouter26.v \
	leafrouter27.v \
	leafrouter28.v \
	leafrouter29.v \
	leafrouter30.v \
	leafrouter31.v \
	leafrouter32.v \
	leafRT.v \
	NI1.v \
	NI2.v \
	NI3.v \
	NI4.v \
	NI5.v \
	NI6.v \
	NI7.v \
	NI8.v \
	NI9.v \
	NI10.v \
	NI11.v \
	NI12.v \
	NI13.v \
	NI14.v \
	NI15.v \
	NI16.v \
	NI17.v \
	NI18.v \
	NI19.v \
	NI20.v \
	NI21.v \
	NI22.v \
	NI23.v \
	NI24.v \
	NI25.v \
	NI26.v \
	NI27.v \
	NI28.v \
	NI29.v \
	NI30.v \
	NI31.v \
	NI32.v \
	spinefsm1.v \
	spinefsm2.v \
	spinefsm3.v \
	spinefsm4.v \
	spinefsm5.v \
	spinefsm6.v \
	spinefsm7.v \
	spinefsm8.v \
	spineport.v \
	spinerouter1.v \
	spinerouter2.v \
	spinerouter3.v \
	spinerouter4.v \
	spinerouter5.v \
	spinerouter6.v \
	spinerouter7.v \
	spinerouter8.v \
	spinerouter9.v \
	spinerouter10.v \
	spinerouter11.v \
	spinerouter12.v \
	spinerouter13.v \
	spinerouter14.v \
	spinerouter15.v \
	spinerouter16.v \
	spinerouter17.v \
	spinerouter18.v \
	spinerouter19.v \
	spinerouter20.v \
	spinerouter21.v \
	spinerouter22.v \
	spinerouter23.v \
	spinerouter24.v \
	spinerouter25.v \
	spinerouter26.v \
	spinerouter27.v \
	spinerouter28.v \
	spinerouter29.v \
	spinerouter30.v \
	spinerouter31.v \
	spinerouter32.v \
	spineRTG1.v \
	spineRTG2.v \
	spineRTG3.v \
	spineRTG4.v \
	spineRTG5.v \
	spineRTG6.v \
	spineRTG7.v \
	spineRTG8.v \
	$(TOP_LEVEL) \
	$(TESTBENCH)

# All source files
ALL_FILES = $(VERILOG_FILES)

.PHONY: all compile run clean view log help

# Default target
all: compile run

# Compile the design
compile:
	@echo "Compiling NoC simulation with $(words $(ALL_FILES)) files..."
	$(SIMULATOR) $(SIM_FLAGS) -o $(EXECUTABLE) $(ALL_FILES)
	@echo "Compilation complete. Executable: $(EXECUTABLE)"

# Run simulation without VCD (for presentations)
run:
	@echo "Running simulation..."
	vvp $(EXECUTABLE)
	@echo "Simulation completed"

# Run simulation with VCD generation
run-vcd:
	@echo "Running simulation with VCD generation..."
	vvp $(EXECUTABLE) +vcd=$(VCD_FILE)
	@echo "Simulation completed. VCD file: $(VCD_FILE)"

# Run simulation and save output to log
run-log:
	@echo "Running simulation with logging..."
	vvp $(EXECUTABLE) | tee $(LOG_FILE)
	@echo "Simulation completed. Log file: $(LOG_FILE)"

# View VCD in gtkwave
view:
	@if [ -f "$(VCD_FILE)" ]; then \
		echo "Opening $(VCD_FILE) in gtkwave..."; \
		$(VCD_VIEWER) $(VCD_FILE) & \
	else \
		echo "VCD file not found. Run 'make run-vcd' first."; \
	fi

# Clean generated files
clean:
	rm -f $(EXECUTABLE) $(VCD_FILE) $(LOG_FILE) *.vcd *.log
	@echo "Clean complete"

# Quick test (compile + run without VCD)
test: compile run

# Display help
help:
	@echo "=== NoC Simulation Makefile ==="
	@echo "make all       - Compile and run simulation"
	@echo "make compile   - Compile only"
	@echo "make run       - Run simulation (no VCD)"
	@echo "make run-vcd   - Run simulation with VCD generation"
	@echo "make run-log   - Run simulation with logging"
	@echo "make view      - View VCD in gtkwave"
	@echo "make test      - Quick test (compile + run)"
	@echo "make clean     - Remove generated files"
	@echo "make help      - Show this help"

# Print file count (useful for verification)
file-count:
	@echo "Total Verilog files: $(words $(ALL_FILES))"


#For presentation (no VCD warnings): make all
#step by step: make compile  # Compile all 200 files
#				make run      # Run simulation without VCD
#For debugging with VCD: make run-vcd  # Run with VCD generation
#						make view     # Open in gtkwave (if needed)
#Quick test: make test
#Check file count: make file-count
#Clean up when done: make clean

#iverilog -g2012 -o noc_sim \
fifo.v \
gpu1.v gpu2.v gpu3.v gpu4.v gpu5.v gpu6.v gpu7.v gpu8.v gpu9.v gpu10.v \
gpu11.v gpu12.v gpu13.v gpu14.v gpu15.v gpu16.v gpu17.v gpu18.v gpu19.v gpu20.v \
gpu21.v gpu22.v gpu23.v gpu24.v gpu25.v gpu26.v gpu27.v gpu28.v gpu29.v gpu30.v \
gpu31.v gpu32.v \
gpuni1router1.v gpuni2router2.v gpuni3router3.v gpuni4router4.v \
gpuni5router1.v gpuni6router2.v gpuni7router3.v gpuni8router4.v \
gpuni9router1.v gpuni10router2.v gpuni11router3.v gpuni12router4.v \
gpuni13router1.v gpuni14router2.v gpuni15router3.v gpuni16router4.v \
gpuni17router1.v gpuni18router2.v gpuni19router3.v gpuni20router4.v \
gpuni21router1.v gpuni22router2.v gpuni23router3.v gpuni24router4.v \
gpuni25router1.v gpuni26router2.v gpuni27router3.v gpuni28router4.v \
gpuni29router1.v gpuni30router2.v gpuni31router3.v gpuni32router4.v \
group1.v group2.v group3.v group4.v group5.v group6.v group7.v group8.v \
leaffsm1.v leaffsm2.v leaffsm3.v leaffsm4.v leaffsm5.v leaffsm6.v leaffsm7.v leaffsm8.v \
leafport.v \
leafrouter1.v leafrouter2.v leafrouter3.v leafrouter4.v \
leafrouter5.v leafrouter6.v leafrouter7.v leafrouter8.v \
leafrouter9.v leafrouter10.v leafrouter11.v leafrouter12.v \
leafrouter13.v leafrouter14.v leafrouter15.v leafrouter16.v \
leafrouter17.v leafrouter18.v leafrouter19.v leafrouter20.v \
leafrouter21.v leafrouter22.v leafrouter23.v leafrouter24.v \
leafrouter25.v leafrouter26.v leafrouter27.v leafrouter28.v \
leafrouter29.v leafrouter30.v leafrouter31.v leafrouter32.v \
leafRT.v \
NI1.v NI2.v NI3.v NI4.v NI5.v NI6.v NI7.v NI8.v NI9.v NI10.v \
NI11.v NI12.v NI13.v NI14.v NI15.v NI16.v NI17.v NI18.v NI19.v NI20.v \
NI21.v NI22.v NI23.v NI24.v NI25.v NI26.v NI27.v NI28.v NI29.v NI30.v \
NI31.v NI32.v \
spinefsm1.v spinefsm2.v spinefsm3.v spinefsm4.v spinefsm5.v spinefsm6.v spinefsm7.v spinefsm8.v \
spineport.v \
spinerouter1.v spinerouter2.v spinerouter3.v spinerouter4.v \
spinerouter5.v spinerouter6.v spinerouter7.v spinerouter8.v \
spinerouter9.v spinerouter10.v spinerouter11.v spinerouter12.v \
spinerouter13.v spinerouter14.v spinerouter15.v spinerouter16.v \
spinerouter17.v spinerouter18.v spinerouter19.v spinerouter20.v \
spinerouter21.v spinerouter22.v spinerouter23.v spinerouter24.v \
spinerouter25.v spinerouter26.v spinerouter27.v spinerouter28.v \
spinerouter29.v spinerouter30.v spinerouter31.v spinerouter32.v \
spineRTG1.v spineRTG2.v spineRTG3.v spineRTG4.v spineRTG5.v spineRTG6.v spineRTG7.v spineRTG8.v \
NOC.v NoCtestbench.v
