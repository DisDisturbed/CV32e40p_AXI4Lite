CV32E40P AXI4-Lite Integration
This repository provides an integrated RTL implementation of the CV32E40P (formerly RI5CY) RISC-V core interfaced with a standard AXI4-Lite bus. The design is organized for immediate integration into Xilinx Vivado and includes hardware-software co-design examples to verify memory-mapped operations.

📂 Project Structure
Plaintext
├── RTL/
│   ├── common_cells/       # Global headers (.svh) and shared IP components
│   ├── core/               # CV32E40P core source files
│   └── axi_wrapper/        # AXI4-Lite interface logic
└── CODES/                  # Software benchmarks for hardware verification
    ├── aes/                # Advanced Encryption Standard test
    └── bubblesort/         # Sorting algorithm test
🛠 Vivado Integration & Setup
To successfully synthesize and simulate the project in Vivado, the tool must be configured to recognize the shared headers inside the common_cells directory.

Run the following commands in the Vivado TCL Console:

1. Define the Global Include Path
Note: Ensure the path points directly to the common_cells folder, not just the root RTL folder.

Tcl
set include_path "/path/to/your/RTL/common_cells/"
2. Apply to Simulation Fileset
Allow the simulator to resolve the global headers:

Tcl
set_property include_dirs $include_path [get_filesets sim_1]
3. Apply to Synthesis Fileset
Ensure the synthesis engine includes the headers for accurate bitstream generation:

Tcl
set_property include_dirs $include_path [get_filesets sources_1]
✅ Verification & Testing
The system is validated against an AXI4-Lite Slave Memory model. The core successfully executes compiled C-code benchmarks, confirming the integrity of instruction fetches, load/store operations, and AXI4-Lite bus protocol compliance.

Included Benchmarks (located in CODES/):

AES: Stresses the core with intensive logic operations and frequent memory accesses to validate data integrity.

Bubblesort: Validates basic sequential load/store operations, loop unrolling, and branching accuracy.
