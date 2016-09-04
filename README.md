MusicBoxNano
============

A small music box program for your DE0nano board.

A MIDI song to be played is stored to memory on the FPGA. When playing, every note in the song generates a waveforms in the correct frequency with a DDS synthesizer which is multiplied with an envelope. With this, each note has a nice "pling" sound, just like a real music box. Eight notes can be played in parallel. A first stage of the project uses a simple PWM ADC to make the sound audible on speakers. To hear the sound, attach a speaker (and maybe a resistor) to the 2x13 pin-header between pin 5 (FPGA PIN_A14) and pin 26 (GND).

This project is more or less a direct FPGA conversion from an assembler music box program for a 8-bit AVR found here: http://elm-chan.org/works/mxb/report.html. The website explaines the working principle in a little more detail. Also, the LUT entries for waveform and envelope functions are directly taken from there.
