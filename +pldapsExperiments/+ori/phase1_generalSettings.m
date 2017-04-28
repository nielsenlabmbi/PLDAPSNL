function s = phase1_generalSettings

% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

%configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

%set reward amounts
s. behavior.   reward. amount = [0.07 0.07 0.07 0.07];

%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0.3;
s.stimulus.stimON = 0.3;
s.stimulus.lickdelay = 1.2;
% s.stimulus.trialduration = 10;
s.stimulus.duration.ITI = 0.3;

%ports
 s. ports.   nPorts = 3;