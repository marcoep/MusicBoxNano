%% generate mif file for DDS waveform RO

% settings
wordwidth_c = 8; % ROM word width
fracwdith_c = 0; % fractional bits

% load source
load('LUTs.mat')

% addresses
atkaddr = [0:numel(AttackLUTVector)-1];
susaddr = numel(AttackLUTVector)+[0:numel(SustainLUTVector)-1];

% show waveform
figure(1)
subplot(2, 1, 1)
plot(atkaddr, AttackLUTVector, '-x', susaddr, SustainLUTVector, '-x')
grid on
xlim([0, susaddr(end)])
title('From elm-chan.org')

% upsample the waveform four-fold (includes resampling lowpass filter)
atk_up = round(resample(AttackLUTVector, 4, 1));
atkaddr_up = [0:4*numel(AttackLUTVector)-1];
sus_up = round(resample(SustainLUTVector, 4, 1));
susaddr_up = 4*numel(AttackLUTVector)+[0:4*numel(SustainLUTVector)-1];

% show upsampled waveform
subplot(2, 1, 2)
plot(atkaddr_up, atk_up, '-x', susaddr_up, sus_up, '-x')
grid on
xlim([0, susaddr_up(end)])
title('Upsampled 4x')

% print address ranges
fprintf('Address %d to %d is Attack Table\n', atkaddr_up(1), atkaddr_up(end));
fprintf('Address %d to %d is the Sustain Table\n', susaddr_up(1), susaddr_up(end));

% prepare output
romout = [atk_up, sus_up];
romsize = numel(atk_up)+numel(sus_up);
romin = 0:romsize-1;


%% Generate MIF file (use this)



datafile = fopen(sprintf('WaveTable_%d.mif', romsize),'w');

fprintf(datafile, 'DEPTH = %i;\n',romsize);
fprintf(datafile, 'WIDTH = %d;\n', wordwidth_c);
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = BIN;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:romsize
    b = fi(romout(i), 1, wordwidth_c, fracwdith_c);
    fprintf(datafile, '%s : %s ;\n', dec2hex(romin(i)), b.bin);
end

fprintf(datafile, 'END;\n');
fclose(datafile);