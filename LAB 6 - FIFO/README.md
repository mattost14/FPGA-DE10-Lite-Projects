# DE10-Lite FPGA: Accumulator using FSM and FIFO with clock crossing domains

Using Lab 5 (Accumulator) as a starting point, implement a revised version on your DE10-Lite development board.  Observe the following requirements:

- One push button is the "reset" button.  Pressing this button clears the accumulated value.
- The 24-bit accumulated value is displayed in hexadecimal on the six 7-segment displays.
- The other push button is the "store" button.  Pressing this button stores the value on the 10 toggle switches in a FIFO.
- When there are 5 items in the FIFO, the FIFO is drained (i.e. the 5 values are added to the previously accumulated value).
- The 10 LEDs reflect the state of the 10 toggle switches.
- The first FSM runs on a 5 MHz clock and manages button presses and the write side of the FIFO
- The second FSM runs on a 12.5 MHz clock and manages the read side of the FIFO and the accumulator.
- This project must be implemented in VHDL and must consist of 2 FSMs, a clock-domain-crossing FIFO, and a PLL.
- Demonstrate your working circuit to the instructor (in-person, Zoom, or video recording).
- Include your VHDL as an appendix to the lab report.
