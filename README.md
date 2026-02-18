# HUL Multiplicity Logic Firmware

Firmware for HUL Multiplicity Logic board (Kintex-7).

## Environment
*   Vivado 2023.1
*   Kintex-7 (xc7k160tfbg676-1)

## Preparation

### 1. Clone Repository

```bash
git clone https://github.com/hyptpc/hul-multiplicity-firmware.git
cd hul-multiplicity-firmware
```

### 2. Download SiTCP Netlist

Download SiTCP netlist files into `firmware/src/sitcp/`.
Example using BeeBeansTechnologies repository:

```bash
cd firmware/src/sitcp/
git clone https://github.com/BeeBeansTechnologies/SiTCP_Netlist_for_Kintex7.git
```

This will place the necessary EDIF/NGC files under `firmware/src/sitcp/SiTCP_Netlist_for_Kintex7/`.
The project generation script will automatically detect files in this subdirectory.

## Project Generation

![howtoopen](https://github.com/user-attachments/assets/a3aba21f-9425-4395-ad71-5e0e5e794edb)

1.  Open Vivado.
2.  Open **Tcl Console** from the bottom panel.
3.  Run the generation script:

```tcl
source firmware/scripts/project_generator.tcl
```

The script will:
1.  Create a new Vivado project in `firmware/project/`.
2.  Add all source files (HDL, IP, Constraints).
3.  Search for SiTCP netlists (preferring .edf/.edif over .ngc).
4.  Set up libraries and synthesis/implementation settings.

## Build

1.  Click **Generate Bitstream** in the Flow Navigator.
2.  Verify timing results after implementation.
