# DE10-Lite FPGA: Accumulator using FSM

Implement a 24-bit accumulator on your DE10-Lite development board.  Observe the following requirements:

- This project must be implemented as a VHDL Finite State Machine (FSM).
- One push button is the "reset" button.  Pressing this button clears the accumulated value (i.e. sets the value to zero).
- The 24-bit accumulated value is displayed in hexadecimal on the six 7-segment displays.
- The other push button is the "add" button.  Pressing this button adds the new value to the accumulated value.  This sum is now stored in the accumulator.
- The new value for the accumulator to consume is a 10-bit unsigned number provided by the 10 toggle switches on your development board.  Using the accumulator entails adjusting the toggle switches to the desired number, then pressing the "add" button to update the accumulator.
- The 10 LEDs reflect the state of the 10 toggle switches.  A logic '1' should turn on the LED, while a logic '0' turns it off.
- Your FSM must de-bounce the "add" button.  In other words, one press of the "add" button should result in exactly one accumulate operation, regardless of the length of time the button is pressed.

This project was part of the ECE 5730 - Reconfigurable Hardware class taken at the Utah State University (USU) in the Fall of 2023.