# HUL Multiplicity Logic Firmware for Debugging

Firmware especially for debugging with HUL (Hardware level).

In this logic, you can monitor up to 3 signals in processing from NIM outputs.

**This logic is still under development**

About SiTCP setting, please refer to main branch's README.

## Preparation and Test

Signal mon_1/mon_2/mon_3 are already declared.

1. Connect objective signals to these.

  ex) mon_1 <= <objective_signal>

2. Run synthesis & implementation, generate bitstream, as usual.

3. Write bitstream file to HUL FPGA

4. Check monitor signals from NIM Outputs.
  mon_1 -> NIMOut2, mon_2 -> NIMOut3, mon_3 -> NIMOut4


**Last Updated:** 2026-02-19  
