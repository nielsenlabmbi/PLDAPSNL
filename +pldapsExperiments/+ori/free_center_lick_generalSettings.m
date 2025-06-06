function s = free_center_lick_generalSettings

% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
s.datapixx.useAsEyepos = 0;
 s.	pldaps.	draw.	eyepos.	use = 1;
 s.	pldaps.	draw.	eyepos.	show = 1;
%configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 %turn mouse input off
s.mouse.useAsPort = 1;
s.mouse.use = 1;

%set reward amounts
s. behavior.   reward. amount = [0.075 0.07 0.07 0.07];

%turn saving off
s.pldaps.nosave = 1;

%misc
s.stimulus.baseline = 0.5;
s.stimulus.lickdelay = 6000;

%ports
 s. ports.   nPorts = 3;