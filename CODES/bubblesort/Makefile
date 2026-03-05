
PREFIX = /usr/bin/riscv64-unknown-elf
CC = $(PREFIX)-gcc
OBJDUMP = $(PREFIX)-objdump
OBJCOPY = $(PREFIX)-objcopy
SPIKE = /home/yusuf/spike/bin/spike
CCFLAGS = -march=rv32imf -mabi=ilp32 \
          -O1 \
          -ffreestanding -fno-builtin -fno-inline \
          -nostdlib -nostartfiles \
          -T linksc.ld \
          -g -ggdb \
          -Wall -Wextra

# Format for 32-bit hex words
HEX_FMT = -v -e '1/4 "%08x\n"'

# -----------------------------------------------------------
# TARGETS
# -----------------------------------------------------------

all: build_hw build_sim

build_hw: bubblesort.c crt0.s
	$(CC) crt0.s bubblesort.c $(CCFLAGS) \
	    -Wl,--defsym=ROM_START=0x00000000 \
	    -Wl,--defsym=RAM_START=0x00000000 \
	    -Wl,--no-check-sections \
	    -DOUTPUT_BASE_ADDR=0x00000000 \
	    -o main_hw.elf
	
	$(OBJDUMP) -D main_hw.elf > hw_dump.txt
	
	# Extract ONLY instruction sections
	$(OBJCOPY) -O binary -j .text -j .text.init main_hw.elf hw_instr.bin
	hexdump $(HEX_FMT) hw_instr.bin > ins.mem
	
	# Extract ONLY data sections
	$(OBJCOPY) -O binary -j .rodata -j .data -j .sdata main_hw.elf hw_data.bin
	hexdump $(HEX_FMT) hw_data.bin > data.mem
	
	@echo "--------------------------------------------------"
	@echo " [HARDWARE] .mem files created (ROM: 0x0, RAM: 0x0)"
	@echo "--------------------------------------------------"

# --- 2. SIMULATION BUILD ---
build_sim: bubblesort.c crt0.s
	$(CC) crt0.s bubblesort.c $(CCFLAGS) \
	    -Wl,--defsym=ROM_START=0x80000000 \
	    -Wl,--defsym=RAM_START=0x80020000 \
	    -DOUTPUT_BASE_ADDR=0x80020000 \
	    -o main_sim.elf
	@echo "--------------------------------------------------"
	@echo " [SIMULATION] ELF created (ROM: 0x80000000, RAM: 0x80020000)"
	@echo "--------------------------------------------------"

# --- RUN SPIKE ---
debug: build_sim
	$(SPIKE) -d --isa=rv32imf main_sim.elf

log: build_sim
	-$(SPIKE) -l --isa=rv32imf main_sim.elf 2> spike_execution.log
	@echo "Checking for writes to Safe RAM (0x8002...)"
	@grep "sw" spike_execution.log | head -n 10 || echo "No stores found."

clean:
	rm -f *.elf *.bin *.mem *.txt *.log