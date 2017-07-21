function s = phase1_generalSettings

% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

%set reward amounts
s. behavior.   reward. amount = [0.1 0.25 0.25];
s.behavior.reward.pulseFreq = 5;
s.behavior.reward.pulseInt = 0.2;

%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0;
s.stimulus.stimON = 0;
s.stimulus.waitTime = 0.25;
s.stimulus.trialduration = 1;
s.stimulus.duration.ITI = 2;

s.stimulus.fracInstruct = 1;

s.stimulus.blocklength = 5;

%ports
 s. ports.   nPorts = 3;