init;

%% Settings

midifilename_c = 'for_elise_by_beethoven.mid';

% specify midi file:
mdi = readmidi(midifilename_c);

Notes = midiInfo(mdi);
[rows,cols] = size(Notes);
channels = unique(Notes(:,1),'rows');

%specify which channels to use:
%c = [2,3,4,5,6];
c = 2;

%specify microseconds per beat (quarter note):
mspc = 857143;


%% calculations

calcconst = 16000000/(mspc); %= 64tel per second

Result = [[]];
cnt = 1;

for i = 1:rows
    if  ~isempty(find(c == Notes(i,1),1))
        if (Notes(i,3) <= 127 && Notes(i,3) >= 0)
            Result(cnt,:) = Notes(i,:);
            cnt = cnt+1;
        else
            fprintf('Found key out of range at %d!\n',cnt);
        end
    end
end

Result = Result(:,1:6);

cust = [[]];
fordebug = [[]];

for i = 1:cnt-2
    cust(i,:) = [Result(i,3), round((Result(i+1,5)-Result(i,5))*calcconst)];
    %fordebug(i,:) = [KeyTable(Result(i,3)-9+1), round((Result(i+1,5)-Result(i,5))*10^6)];
%     if fordebug(i,2) == 0
%         fordebug(i,2) = 5;
%     end
end
    cust(cnt-1,:) = [Result(cnt-1,3)-9, 32];
    %fordebug(cnt-1,:) = [KeyTable(Result(cnt-1,3)-9 + 1), 10^6];
    
lutsize=cnt-1;

lutin = 0:lutsize-1;
    
%% Generate MIF file

datafile = fopen('fuer_elise.mif','w');

fprintf(datafile, 'DEPTH = %d;\n',lutsize);
fprintf(datafile, 'WIDTH = 14;\n');
fprintf(datafile, 'ADDRESS_RADIX = HEX;\n');
fprintf(datafile, 'DATA_RADIX = BIN;\n');
fprintf(datafile, 'CONTENT\n');
fprintf(datafile, 'BEGIN\n');

%output to file
for i = 1:lutsize
    fprintf(datafile, '%s : %s%s ;\n', dec2hex(lutin(i)), dec2bin(cust(i,2),7), dec2bin(cust(i,1),7));
end

fprintf(datafile, 'END;\n');
fclose(datafile);

%% Generate MATLAB simulation output

SongTableKey1068 = @(x) cust(x+1,1);
SongTableDuration1068 = @(x) cust(x+1,2);
save('SongLUT.mat','SongTableKey1068','SongTableDuration1068');


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