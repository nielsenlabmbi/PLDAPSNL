function s = phase0_generalSettings

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
s. behavior.   reward. amount = [0.2 0.2 0.2];
s.behavior.reward.pulseFreq = 8;
s.behavior.reward.pulseInt = 0.2;

%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0;
s.stimulus.stimON = 0.5;
s.stimulus.waitTime = 0.25;
s.stimulus.trialduration = 1;
s.stimulus.duration.ITI = 1.5;

s.stimulus.fracInstruct = 0.7;

%ports
 s. ports.   nPorts = 3;