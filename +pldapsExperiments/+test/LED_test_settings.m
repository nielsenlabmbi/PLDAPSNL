function s = LED_test_settings

%set reward amounts
s. behavior.   reward. amount = [0.01 0.02 0.07];
s.behavior.reward.amountDelta = 0.01;

%set viewing parameters
s.stimulus.LEDCh = [18 20 22];
s.stimulus.LEDChSt = 24; %[16];
s.stimulus.pwd = 0.05;
s.stimulus.numflash = 5;
s.stimulus.trialdur = 1.5;

s.stimulus.lickdelay = 1;
s.stimulus.duration.ITI = 0.5;
s.stimulus.stimON = 0.3;
s.stimulus.waitTime = 0;

%set eye tracking parameters
s.datapixx.useAsEyepos = 1;
 s.	pldaps.	draw.	eyepos.	use = 1;
 s.	pldaps.	draw.	eyepos.	show = 1;
 
%set up the viewing distance
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 s.datapixx.useAsEyepos = 1;
% % 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% turn saving off
s.pldaps.nosave = 1;