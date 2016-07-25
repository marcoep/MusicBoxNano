%% Generate a Key to Freq LUT mif file.

% this file generates a static song ROM .mif file with 6 bits as duration
% and 6 bits pitch data. (OLD!)

%% Generate all values.
% define song data
title_c = 'LetItBe-Beatles';
pitch_c = [61,34,34,34,34,36,31,34,34,39,41,43,43,43,41,41,39,39,43,43,44,43,43,41,61,43,41,41,39,61,34,34,34,36,39,34,34,39,41,41,43,43,41,41,39,39,43,43,44,43,43,41,61,43,41,41,39,43,41,39,43,46,48,46,46,46,43,41,39,36,34,43,39,43,43,44,43,43,41,61,43,41,41,39];
duration_c = [4,2,2,4,2,6,4,4,4,2,6,2,4,6,4,4,4,8,2,6,4,2,6,4,4,2,2,4,20,6,2,2,6,4,2,6,4,2,6,2,6,4,2,4,4,20,2,6,4,2,6,4,4,2,2,2,22,2,4,10,2,4,6,4,2,4,4,2,4,2,4,6,12,2,4,6,2,6,4,2,2,2,6,20];

% move low pitches one octave higher
p = [];
for i = pitch_c;
    if i < 49
        p = [p, i+12];
    else
        p = [p, i];
    end
    
end


% define LUT input
if (size(pitch_c) ~= size(duration_c))
    error('sizes dont match!');
end
lutsize = size(pitch_c); lutsize = lutsize(2);
lutin = 0:lutsize-1;

%% Generate MIF file

datafile = fopen([title_c '-musicbox.mif'],'w');

fprintf(datafile, 'DEPTH = %d;\n',lutsize);
fprintf(datafile, 'WIDTH = 12;\n');
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = BIN;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:lutsize
    fprintf(datafile, '%s : %s%s ;\n', dec2hex(lutin(i)), dec2bin(duration_c(i),6), dec2bin(pitch_c(i),6));
end

fprintf(datafile, 'END;\n');
fclose(datafile);