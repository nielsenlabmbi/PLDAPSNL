function s = eye_test_settings


%set reward amounts
s. behavior.   reward. amount = [0.04 0.08 0.08];
s.behavior.reward.amountDelta = 0.01;

%set orientation and offsets
% s.stimulus.offsets = {[0:22.5:90]};
% s.stimulus.angle = 0;
% s.stimulus.sf = 0.08;
% s.stimulus.range = 121;
s.	display.	bgColor = [ 0    0   0 ];
s.stimulus.color = 1;
s.stimulus.size = {[-40 -40 40 40]};
% s.stimulus.position = [{[960 540 960 540]} {1880 540 1880 540} {40 540 40 540} ...
%     {1880 1040 1880 1040} {960 1040 960 1040} {40 1040 40 1040} {1880 40 1880 40}...
%     {960 40 960 40} {40 40 40 40}];
s.stimulus.direction = [0 90 180 270];
s.stimulus.limits = {[420 0 1500 1080]};

s.stimulus.pursuit = [1 0];
s.stimulus.dFrame = 10;

s.stimulus.baseline = 0.5;
s.stimulus.reference_baseline = 0.5;
s.stimulus.stimON = 1;
s.stimulus.stimdur = 1;
s.stimulus.waitTime = 1;
s.stimulus.runtype = 'pseudo';
s.stimulus.lickdelay = 1.5;
s.stimulus.duration.ITI = 2;
%set up the viewing distance
s.display.viewdist = 45; 
% 
s.datapixx.useAsEyepos = 1;
 s.	pldaps.	draw.	eyepos.	use = 1;
 s.	pldaps.	draw.	eyepos.	show = 1;
 

% %configure ports
 s.ports.use = true;
 s.ports.nPorts = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5];
 
 s.datapixx.din.useFor.ports = 1;
 

%%% Debugging settings

% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% s.datapixx.useAsPorts = 0;
% % % turn saving off
% s.pldaps.nosave = 1;
