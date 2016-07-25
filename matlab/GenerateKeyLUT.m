%% Generate a Key to Freq LUT mif file.

%Set Reference Frequency
Fref_c = 64000;


%% Generate all values.

% Define LUT size, there are 128 different midi keys defined:
lutsize = 128;

% address range for LUT
lutin = 0:lutsize-1;

% see http://subsynth.sourceforge.net/midinote2freq.html
fvec = ones(1,lutsize);
fvec(1) = 13.75*2^(-9/12); % 13.75 Hz is the base frequency, it matches A-1 and has the midi key 9, midi key 0 has C-1

% calculate frequencies in Hertz for every midi key
for i = 2:lutsize
    fvec(i) = fvec(1)*realpow(2,(i-1)/12);
end

lutout = round(2^25 * fvec/Fref_c); % 1/8th of the wavetable is the sustain vector.
                                  % the wavetableaddress-counter is 29 bits
                                  % wide and therefore if we want to play a
                                  % frequency of Fref we need to add 2^25
                                  % each step to the phase counter.

% double check what we have done
figure(1)
plot(lutin,fvec./Fref_c)
figure(2)
plot(lutin, lutout)


%% Generate MIF file

datafile = fopen('Key_AllMidiP1Octave_LUT.mif','w');

fprintf(datafile, 'DEPTH = %d;\n',lutsize);
fprintf(datafile, 'WIDTH = 23;\n');
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = HEX;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:lutsize
    fprintf(datafile, '%s : %s ;\n', dec2hex(lutin(i)), dec2hex(lutout(i)));
end

fprintf(datafile, 'END;\n');
fclose(datafile);

%% Generate MATLAB simulation output

KeyTable128 = @(x) lutout(x+1);
save('KeyLUT.mat','KeyTable128');

%% Generate TestVectors

% datafile = fopen('FreqTestVectors.vhd','w');
% 
% %output to file
% for i = 1:lutsize
%     fprintf(datafile,'NewFreqDataxTI <= "%s";\n', dec2bin(lutout(i),23));
%     fprintf(datafile,'NewNoteIntxTI <= ''1'';\n');
%     fprintf(datafile,'wait for note_period/2;\n');
%     fprintf(datafile,'NewNoteIntxTI <= ''0'';\n');
%     fprintf(datafile,'wait for note_period/2;\n');
% end
% fclose(datafile);