function s = dots_FBAB9Settings
% add eye tracking
% s.datapixx.useAsEyepos = 1;
%  s.	pldaps.	draw.	eyepos.	use = 1;
%  s.	pldaps.	draw.	eyepos.	show = 1;
 
%set reward amounts
s. behavior.   reward. amount = [0.01 0.07 0.07];
s.behavior.reward.pulseFreq = 3;
s.behavior.reward.pulseInt = 0.2;
s.behavior.reward.amountDelta = 0.01;


%set orientation and offsets
s.stimulus.dotSize = 1.5;
s.stimulus.nrDots = 250;
s.stimulus.fractionBlack = 0.5;
s.stimulus.direction = [0 180];
s.stimulus.dotCoherence = 1;%[1 1 0.8 0.6 0.4 0.2];
s.stimulus.dotSpeed = 0.6;
s.stimulus.dotLifetime = 240;
s.stimulus.durStim = 60;
s.stimulus.frameRate = 120;

%set viewing parameters

%set viewing parameterses
s.stimulus.baseline = 0.1;
s.stimulus.lickdelay = 1.5;
s.stimulus.forceCorrect_delay = 0.75;
s.stimulus.duration.ITI = 2;
s.stimulus.stimON = 0.5;
s.stimulus.waitTime = 0.5;
s.stimulus.trialdur = 300;
s.stimulus.timeout = 1;

%set instructive trials
s.stimulus.fracInstruct = 1;

%set up the viewing distance
s.display.viewdist = 45; 

% %configure ports
 s.ports.use = true;
 s.ports.nports = 3;
 s.ports.movable = true;
 s.datapixx.adc.channels = [1 3 5]; %[1 3 5 10 11];
 %s.datapixx.useAsEyepos = 0;
 %use din?
 s.datapixx.din.useFor.ports = 1;
 %turn mouse input off
s.mouse.useAsPort = 0;
s.mouse.use = 0;

% 2P room settings
%  s.datapixx.dio.useForReward = 1; 
%  s.datapixx.adc.useForReward = 0;
%  s. behavior.   reward. channel. START = 7; %dio channel for reward delivery
%  s. behavior.   reward. channel. LEFT = 6;
%  s. behavior.   reward. channel. RIGHT = 5;
% 
% 
% %%% Debugging settings
% 
% %turn adc channels off
% s.datapixx.useAsPorts = 0;
% s.datapixx.adc.channels = [];
% 
% %turn mouse input on
% s.mouse.useAsPort = 1;
% s.mouse.use = 1;
% 
% % turn saving off
% s.pldaps.nosave = 1;