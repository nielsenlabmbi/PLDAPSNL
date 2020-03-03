function s = free_lick_generalSettings

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
s. behavior.   reward. amount = [0.02 0.07 0.07 0.02];
s.behavior.reward.amountDelta = 0.01;
%s. behavior.reward. manualAmount = 0.02;
%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0.5;
s.stimulus.lickdelay = 3600;
s.stimulus.fracInstruct = 0;

%ports
 s. ports.   nPorts = 3;
 
 s.datapixx.din.useFor.ports = 1;