%% calculate
load('LUTs.mat')

% settings
wordwidth_c = 8; % ROM word width
fracwdith_c = 0; % fractional bits

% addresses
envaddr = [0:numel(EnvelopeLUTVector)-1];

% show envelope
figure(1)
plot(envaddr, EnvelopeLUTVector, '-x')
grid on
axis([0, envaddr(end), 0, 255])
title('From elm-chan.org')
fprintf('Address 0 to 255 is the Envelope LUT\n');


% print address ranges
fprintf('Address %d to %d is Envelope Table\n', envaddr(1), envaddr(end));

% prepare output
romout = EnvelopeLUTVector;
romsize = numel(romout);
romin = 0:romsize-1;


%% Generate MIF file (use this)

datafile = fopen(sprintf('Envelope_%d.mif', romsize),'w');

fprintf(datafile, 'DEPTH = %i;\n', lutsize);
fprintf(datafile, 'WIDTH = %d;\n', wordwidth_c);
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = BIN;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:lutsize
    b = fi(romout(i), 0, wordwidth_c, fracwdith_c);
    fprintf(datafile, '%s : %s ;\n', dec2hex(lutin(i)), b.bin);
end

fprintf(datafile, 'END;\n');
fclose(datafile);