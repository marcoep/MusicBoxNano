%% Attack and Sustain LUT

load('LUTs.mat')
v = [AttackLUTVector,SustainLUTVector];

origx = linspace(0,1023,1024);
newx = linspace(0,1023,4096);
vnew = interp1(origx,v,newx,'pchip');

fprintf('Address 0 to 3583 is Attack Table\nAddress 3584 to Address 4095 is the Sustain Table\n');

lutsize = 4096;

lutin = 0:4095;
lutout = int8(vnew);

WaveTable4096 = @(x) lutout(x+1);

%% Envelope

lutout = uint8(EnvelopeLUTVector);
fprintf('Address 0 to 255 is the Envelope LUT\n');
EnvTable256 = @(x) lutout(x+1);


%% save to file

save('WaveEnvLUTs.mat','WaveTable4096','EnvTable256');