CV32E40P AXI4-Lite Integration
This repository provides an implementation of the CV32E40P RISC-V core interfaced with an AXI4-Lite bus. The project is structured for easy integration into Xilinx Vivado environments and includes verified test cases for memory-mapped operations.

Directory Structure
RTL/: Contains the SystemVerilog source files for the core and bus logic.

common_cells/: A dedicated subdirectory for shared header files (.svh) and common IP components.

CODES/: Software benchmarks used for hardware verification.

aes/: Advanced Encryption Standard implementation.

bubblesort/: Standard sorting algorithm test.

Vivado Setup & Header Integration
To ensure Vivado correctly identifies the global headers and includes within the common_cells folder, follow these steps in the TCL Console:

1. Define the Include Path
Set the path variable pointing to your RTL directory (adjust the string to match your local machine's path):

Tcl
set include_path "/path/to/your/RTL/folder/" 
2. Apply to Simulation
Enable the headers for the simulation environment:

Tcl
set_property include_dirs $include_path [get_filesets sim_1]
3. Apply to Synthesis
Enable the headers for the synthesis engine to ensure the bitstream generates correctly:

Tcl
set_property include_dirs $include_path [get_filesets sources_1]
Verification & Testing
The current system has been rigorously tested using an AXI4-Lite Slave Memory model. The hardware-software co-design successfully executes complex algorithms, ensuring the bus protocol timing and data integrity are maintained.

Verified Benchmarks:

AES: Validates complex data processing and intensive memory access.

Bubblesort: Confirms basic load/store operations and branching logic accuracy.

Note: All benchmark source code and compiled binaries can be found in the CODES/ directory.
