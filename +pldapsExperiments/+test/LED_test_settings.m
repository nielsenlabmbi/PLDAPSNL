function s = LED_test_settings

%set reward amounts
s. behavior.   reward. amount = [0.08 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set viewing parameters
s.stimulus.LEDCh = [16 18 20 22];
s.stimulus.LEDChSt = 18;%[16 18 20 22];
s.stimulus.pwd = 0.05;
s.stimulus.trialdur = 2;

s.stimulus.lickdelay = 1.5;
s.stimulus.duration.ITI = 1;
%s.stimulus.waitTime = 0;

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
%s.pldaps.nosave = 1;