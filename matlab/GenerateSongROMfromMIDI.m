init;

%% Settings

midifilename_c = 'for_elise_by_beethoven.mid';
tickwidth_c = 10;
pitchwidth_c = 7;

% specify midi file:
mdi = readmidi(midifilename_c);

Notes = midiInfo(mdi);
[rows,cols] = size(Notes);
channels = unique(Notes(:,1),'rows');

%specify which channels to use:
%c = [2,3,4,5,6];
c = [2];


%% calculations

% we have a 250 Hz clock driving the new-note ticks
tickfreq = 250;

% remove all notes which do not belong to the desired channels
ourrows = ismember(Notes(:,1), c);
ourNotes = Notes(ourrows, :);

% midi key (=pitch) is in 3rd column
pitches = ourNotes(:,3);

% figure out delta ticks between notes
starttimes = ourNotes(:,5);
deltatimes = [diff(starttimes); 0]; % [s]
deltaticks = round(deltatimes*tickfreq);
deltaticks(end) = 2^tickwidth_c-1; % set last note to max, to get a nice pause

% convert to binary
ticksbin = fi(deltaticks, 0, tickwidth_c, 0);
pitchesbin = fi(pitches, 0, pitchwidth_c, 0);

% setup lut
lutsize = numel(pitches);
lutin = 0:lutsize-1;
    
%% Generate MIF file

datafile = fopen([midifilename_c '-musicbox.mif'],'w');

fprintf(datafile, 'DEPTH = %d;\n', lutsize);
fprintf(datafile, 'WIDTH = %d;\n', tickwidth_c+pitchwidth_c);
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = BIN;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:lutsize
    t = ticksbin(i);
    p = pitchesbin(i);
    fprintf(datafile, '%s : %s%s ;\n', dec2hex(lutin(i)), t.bin, p.bin);
end

fprintf(datafile, 'END;\n');
fclose(datafile);

%% Generate MATLAB simulation output

% SongTableKey1068 = @(x) cust(x+1,1);
% SongTableDuration1068 = @(x) cust(x+1,2);
% save('SongLUT.mat','SongTableKey1068','SongTableDuration1068');


%% Generate Simulation VHDL
% 
% datafile = fopen('fuer_elise_SIM.vhd','w');
% 
% %output to file
% for i = 1:lutsize
%     fprintf(datafile, 'NewNoteIntxSI <= ''1'';\n');
%     fprintf(datafile, 'NewFreqDataxDI <= "%s";\n', dec2bin(fordebug(i,1),23));
%     fprintf(datafile, 'wait for %d ns;\n', round(fordebug(i,2)/2));
%     fprintf(datafile, 'NewNoteIntxSI <= ''0'';\n');
%     fprintf(datafile, 'wait for %d ns;\n', round(fordebug(i,2)/2));
% end
% 
% fclose(datafile);