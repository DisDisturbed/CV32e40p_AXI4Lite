# CV32E40P RISC-V Core (AXI4-Lite Version)

![Status: Verified](https://img.shields.io/badge/Status-Verified-brightgreen)
![Bus: AXI4-Lite](https://img.shields.io/badge/Bus-AXI4--Lite-blue)

This repository contains the **CV32E40P** (RI5CY) RISC-V core integrated with an **AXI4-Lite** interface. This integration allows for standardized communication with memory-mapped slaves and peripherals within the Xilinx Vivado ecosystem.

---

## 📂 Repository Structure

* **RTL/**: Core hardware source files.
    * **common_cells/**: **(New)** Contains global header files (`.svh`) and shared logic components.
* **CODES/**: Software benchmarks for hardware verification.
    * `aes/`: Advanced Encryption Standard implementation.
    * `bubblesort/`: Standard sorting algorithm for logic/branch testing.

---

## 🛠 Vivado Setup & Header Integration

To ensure Vivado correctly identifies the global headers in the `common_cells` folder, execute the following commands in the **Vivado TCL Console**.

> **Note:** Replace `"/path/to/your/RTL/common_cells/"` with your actual local directory path.

### 1. Set the Include Path
```tcl
set include_path "/path/to/your/RTL/common_cells/"
```
### 2. Configure Simulation
```tcl
set_property include_dirs $include_path [get_filesets sim_1]
```
### 3. Configure Synthesis
``` tcl
set_property include_dirs $include_path [get_filesets sources_1]
```

✅ Verified Benchmarks
The current system has been rigorously tested against an AXI4-Lite Slave Memory model. The following software tests, located in the CODES/ folder, have passed successfully:

Test Case,Description,Validates
AES,Symmetric Encryption,Intensive data processing and memory throughput.
Bubblesort,Integer Sorting,Basic Load/Store operations and branch accuracy.
