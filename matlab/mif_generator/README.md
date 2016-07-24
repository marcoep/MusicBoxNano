Generation of .mif Files for ROMs
=================================


===Wavetable and Envelope Source Files===

ROM entries for the attack LUT, the sustain LUT, and the envelope LUT are given in the three files:

* LUT_attack.csv
* LUT_sustain.csv
* LUT_envelope.csv

These LUTs are taken directly from the role model of this project, found at http://elm-chan.org/works/mxb/report.html. The LUTs.mat file contains the three LUTs as vectors.

===Generation of .mif Files===

Run either GenerateAttackAndSinusLUT.m or GenerateEnvelopeLUT.m to generate the .mif files for the waveform ROM resp. the envelope ROM. Currently, the waveform is upsampled four-fold compared to the source file.
