# DE10-Lite FPGA: Random Number Generator

This VHDL project implements a random number generator with the following requirements:
- Use a maximum length linear feedback shift register of an appropriate size and
polynomial
- Two input buttons, a reset button, and a generate button
- Generates a two-digit hexadecimal pseudo-random (hexadecimal 00 to FF or decimal 0
to 255)
- These random numbers must be displayed on the seven-segment display
- The reset button will present the seed value on the show.
- The generator must include 0x00

This project was part of the ECE 5730 - Reconfigurable Hardware class taken at the Utah State University (USU) in the Fall of 2023.